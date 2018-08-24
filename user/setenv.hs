{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase                 #-}
{-# LANGUAGE NoImplicitPrelude          #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE StrictData                 #-}
{-# LANGUAGE TemplateHaskell            #-}

-- | This script assumes it is started from the ROOT_DIR of the devbox
module Main where

import qualified Control.Foldl                             as Fold
import           Control.Lens                              hiding (noneOf)
import qualified Data.Text                                 as Text
import           Data.Text.Prettyprint.Doc                 (Doc, pretty, (<+>), annotate, line)
import qualified Data.Text.Prettyprint.Doc.Render.Terminal as PP
import           Dhall                                     hiding (Text, auto,
                                                            input, text)
import qualified Dhall
import qualified Paths_devbox_user
import qualified System.IO                                 as System
import           Turtle                                    hiding (strict, view)

import           Protolude                                 hiding (FilePath,
                                                            die, find, fold,
                                                            (%))

eclipseVersion = "4.7"
eclipseFullVersion = eclipseVersion <> ".3"
eclipsePluginList = ["jdt", "yedit", "testng"]

cicdshellTag =  "v2.5.5"

mrRepoUrl = "git://github.com/CIRB/vcsh_mr_template.git"

-- pinned user env pkgs
nixpkgsPinFile :: IO [Char]
nixpkgsPinFile = do
  datadir <- Paths_devbox_user.getDataDir
  pure $ datadir <> "/share/pin.nix"

data MrRepo
  = MrRepo
  { _path     :: Text
  , _checkout :: Text
  } deriving (Generic, Show)

data Console
  = Console
  { _color :: Text
  } deriving (Generic, Show)

data BoxConfig
  = BoxConfig
  { _userName        :: Text
  , _userEmail       :: Text
  , _loginId         :: Text
  , _repos           :: Vector Text
  , _eclipse         :: Bool
  , _wallpaper       :: Text
  , _console         :: Console
  , _additionalRepos :: Vector MrRepo
  , _envPackages     :: Vector Text
  } deriving (Generic, Show)

makeLenses ''Console
makeLenses ''MrRepo
makeLenses ''BoxConfig

instance Interpret Console
instance Interpret MrRepo
instance Interpret BoxConfig

data ScriptEnv
  = ScriptEnv
  { _boxConfig :: BoxConfig
  , _homeDir   :: FilePath
  } deriving Show

makeLenses ''ScriptEnv

-- The Application Monad. A simple wrapper around ReaderT
newtype AppM a =
  AppM {
    unAppM :: ReaderT ScriptEnv IO a
  } deriving (Functor, Applicative, Monad, MonadIO, MonadReader ScriptEnv)

scriptEnv :: IO ScriptEnv
scriptEnv =
   ScriptEnv <$> Dhall.input auto "/vagrant/config/box.dhall"
             <*> home
  where
    auto ::  Interpret a => Dhall.Type a
    auto = autoWith
      ( defaultInterpretOptions { fieldModifier = Text.dropWhile (== '_') })

installPkKeys :: AppM ()
installPkKeys = do
  printf "\nSynchronizing ssh keys\n"
  testdir "/vagrant/ssh-keys" >>= \case
    False -> ppFailure "No ssh-keys directory found. You won't be able to push anything to 'stash.cirb.lan'."
    True -> do
      homedir <- view homeDir
      let ssh_guestdir = homedir </> ".ssh/"
          ssh_hostdir = "/vagrant/ssh-keys"
      cp "user/ssh-config" (ssh_guestdir </> "config")
      sync_pubkeys ssh_hostdir ssh_guestdir
      sync_privatekeys ssh_hostdir ssh_guestdir
  where
    sync_pubkeys hostdir guestdir = sh $ do
      pk <- find (suffix ".pub") hostdir
      procs "rsync" [ "--chmod=644"
                    , format fp pk
                    , format fp guestdir] empty
    sync_privatekeys hostdir guestdir = sh $ do
      pk <- find (star (noneOf ".")) hostdir
      procs "rsync" [ "--chmod=600"
                    , format fp pk
                    , format fp guestdir] empty
      printf ("Synchronize "%fp%" \n") pk

installMrRepos :: AppM ()
installMrRepos =  do
  printf "\nInstalling mr repos\n"
  homedir <- view homeDir
  add_rx <- view (boxConfig.additionalRepos)
  rx <- view (boxConfig.repos)
  bootstrap <- not <$> testfile (homedir </> ".mrconfig")
  when bootstrap $ do
    clone_mr mrRepoUrl
    add_repo_to_mr add_rx
  activate_repos homedir rx
  let mr_args = [ "-d", format fp homedir
                , "up", "-q"
                ]
  proc "mr" (if bootstrap then "-f" : mr_args else mr_args) empty >>= \case
    ExitFailure _ -> ppFailure "Unable to update all mr repositories\n"
    ExitSuccess   -> ppSuccess "mr repositories\n"
  where
    clone_mr url = do
      proc "vcsh" ["clone"
                  , url
                  , "mr"] empty >>= \case
         ExitFailure _ -> do
           ppFailure ("Unable to clone mr" <+> pretty url <> "\n")
           die "Aborting user configuration"
         ExitSuccess   -> ppSuccess ("Clone mr" <+> pretty url <> "\n")
    add_repo_to_mr rx = sh $ do
      r <- select rx
      let
        path' = r^.path
        checkout' = r^.checkout
      proc "mr" [ "config"
                 , path'
                 , "checkout = " <> checkout'
                ] empty >>= \case
         ExitFailure _ -> do
           ppFailure ("Unable to add" <+> pretty checkout' <+> "to mr\n")
           die "Aborting user configuration"
         ExitSuccess   -> printf ("Add "%s%" to mr\n") checkout'
    activate_repos home_dir rx = sh $ do
      let mrconfigd = home_dir </> ".config/mr/config.d"
      -- delete all mr links to achieve some synchronization with the box.dhall configuration
      -- don't delete other links such as vcsh links !
      proc "find" [ format (fp%"/*.mr") mrconfigd, "-type", "l", "-delete" ] empty
      r <- select rx
      unless (Text.null r) $ do
        let link_target = format ("../available.d/"%s) r
            link_name = format (fp%"/.config/mr/config.d/"%s) home_dir r
        procs "ln" [ "-sf", link_target, link_name] empty
        printf ("Activate "%s%"\n") r

installDoc :: AppM ()
installDoc = do
  exitcode <- shell "make doc > /dev/null" empty
  case exitcode of
    ExitFailure _ -> ppFailure "documentation not installed successfully.\n"
    ExitSuccess   -> do
      homedir <- view homeDir
      let docdir = homedir </> ".local/share/"
      mktree docdir
      proc "cp" ["-r", "doc", format fp docdir] empty
      ppSuccess "documentation\n"

installEclipse :: AppM ()
installEclipse = do
  eclipse <- view (boxConfig.eclipse)
  when eclipse install_eclipse
  where
    install_eclipse = do
      pin <- liftIO nixpkgsPinFile
      let tag = Text.concat (Text.splitOn "." eclipseVersion)
      proc "nix-env" [ "-Q", "--quiet"
                     , "-f" , toS pin
                     , "-i"
                     , "-E", "pkgs: with pkgs {}; eclipses.eclipseWithPlugins { eclipse = eclipses.eclipse-sdk-" <> tag <> "; jvmArgs = [ \"-javaagent:${lombok.out}/share/java/lombok.jar\" ];plugins = with eclipses.plugins; [ " <> Text.unwords eclipsePluginList <> " ]; }"
                     ] empty >>= \case
        ExitSuccess   -> do
          ppSuccess $ "eclipse" <> "\n"
          install_plugin "org.eclipse.egit" "http://download.eclipse.org/releases/oxygen/" "org.eclipse.egit.feature.group"
          install_plugin "org.eclipse.m2e" "http://download.eclipse.org/releases/oxygen/" "org.eclipse.m2e.feature.feature.group"
        ExitFailure _ -> ppFailure $ "enable to install" <+> "eclipse" <+> "\n"
    install_plugin full_name repository installIU = do
      homedir <- view homeDir
      let localdir = homedir </> ".eclipse"
          installPath = localdir </> fromText ("org.eclipse.platform_" <> eclipseFullVersion)
          prefix_fp = installPath </> "plugins" </> fromText full_name
      not_installed <- testdir installPath >>= \case
        True -> fold (find (prefix (text (format fp prefix_fp))) installPath) Fold.null
        False -> pure True
      when not_installed $ do
        printf ("About to download Eclipse "%s%". Hold on.\n") full_name
        exitcode <- proc "eclipse" [ "-application", "org.eclipse.equinox.p2.director"
                                   , "-repository", repository
                                   , "-installIU", installIU
                                   , "-tag", "InitialState"
                                   , "-profile", "SDKProfile"
                                   , "-profileProperties", "org.eclipse.update.install.features=true"
                                   , "-p2.os", "linux"
                                   , "-p2.ws", "gtk"
                                   , "-p2.arch", "x86"
                                   , "-roaming"
                                   , "-nosplash"
                                   ] empty
        case exitcode of
          ExitFailure _ -> ppFailure ("Eclipse plugin" <+> pretty full_name <+> "won't installed\n")
          ExitSuccess -> ppSuccess ("Eclipse plugin" <+> pretty full_name <+> "\n")

configureGit :: AppM ()
configureGit = do
  printf "Configuring git\n\n"
  user_name <- view (boxConfig.userName)
  user_email <- view (boxConfig.userEmail)
  unless (Text.null user_name) $ procs "git" [ "config", "--global", "user.name", user_name] empty
  unless (Text.null user_email) $ procs "git" [ "config", "--global", "user.email", user_email] empty

configureWallpaper :: AppM ()
configureWallpaper = do
  printf "Configuring wallpaper\n\n"
  homedir <- view homeDir
  filename <- view (boxConfig.wallpaper)
  let link_target = homedir </> ".wallpaper" </> fromText filename
      link_name = homedir </> ".wallpaper.jpg"
  procs "ln" [ "-sf"
             , format fp link_target
             , format fp link_name
             ] empty

configureConsole :: AppM ()
configureConsole = do
  printf "Configuring console\n\n"
  homedir <- view homeDir
  color <- view (boxConfig.console.color)
  let color_fp = homedir </> ".config/termite"
      link_target = color_fp </> fromText color
      link_name = color_fp </> "config"
  procs "ln" [ "-sf"
             , format fp link_target
             , format fp link_name
             ] empty

installEnvPackages :: AppM ()
installEnvPackages = do
  pin <- liftIO nixpkgsPinFile
  px <- view (boxConfig.envPackages)
  sh $ do
    p <- select px
    proc "nix-env" [ "-Q", "--quiet"
                   , "-iA", p
                   , "-f" , toS pin
                   ] empty >>= \case
      ExitSuccess   -> ppSuccess $ pretty p <> "\n"
      ExitFailure _ -> ppFailure $ "enable to install" <+> pretty p <+> "\n"


setLoginIdEnv :: AppM ()
setLoginIdEnv = do
  homedir <- view homeDir
  loginid <- view (boxConfig.loginId)
  let
    zshenv = homedir </> ".zshenv"
    appendline = "export LOGINID='" <> loginid <> "'"
  not_found <- fold (grep (text appendline) (input zshenv)) Fold.null
  when not_found $ do
    printf "Appending LOGINID env variable to .zshenv\n"
    append zshenv (pure $ unsafeTextToLine appendline)

installCicdshell :: AppM ()
installCicdshell = do
    proc "nix-env" [ "-Q"
                   , "-i"
                   , "-f" , "https://github.com/CIRB/cicd-shell/archive/" <> cicdshellTag <> ".tar.gz"
                   ] empty >>= \case
      ExitSuccess   -> ppSuccess "cicd-shell\n"
      ExitFailure _ -> ppFailure $ "enable to install the cicd-shell\n"

main :: IO ()
main = do
  System.hSetBuffering System.stdout System.LineBuffering
  let actions = [ installPkKeys
                , installMrRepos
                , configureGit
                , configureWallpaper
                , configureConsole
                , installEnvPackages
                , installDoc
                , installCicdshell
                , setLoginIdEnv
                , installEclipse
                ]
  printf "\n> Setup user configuration\n"
  runApp (sequence_ actions) =<< scriptEnv
  printf "< User configuration completed\n"
  where
    runApp = runReaderT . unAppM

-- UTILS

ppFailure :: MonadIO io => Doc PP.AnsiStyle -> io ()
ppFailure msg = liftIO $ PP.putDoc $ (annotate (PP.color PP.Red) "FAILURE:" <+> msg) <> line

ppSuccess :: MonadIO io => Doc PP.AnsiStyle -> io ()
ppSuccess msg = liftIO $ PP.putDoc $ (annotate (PP.colorDull PP.Green) "Done with" <+> msg) <> line

isFileEmpty :: MonadIO io => FilePath -> io Bool
isFileEmpty path =
  fold (input path) Fold.null
