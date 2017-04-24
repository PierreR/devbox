{-# LANGUAGE DeriveGeneric      #-}
{-# LANGUAGE FlexibleContexts   #-}
{-# LANGUAGE LambdaCase         #-}
{-# LANGUAGE NoImplicitPrelude  #-}
{-# LANGUAGE OverloadedStrings  #-}
{-# LANGUAGE StrictData         #-}
{-# LANGUAGE TemplateHaskell    #-}

-- | This script assumes it is started from the ROOT_DIR of the devbox
module Main where

import qualified Control.Foldl                as Fold
import           Control.Lens                 hiding (noneOf)
import qualified Data.Text                    as Text
import qualified Data.Text.Lazy               as Text.Lazy
import           Dhall                        hiding (Text, auto, input, text)
import qualified Dhall
import qualified System.IO                    as System
import           Text.PrettyPrint.ANSI.Leijen (dullgreen, line, putDoc, red,
                                               (<+>))
import qualified Text.PrettyPrint.ANSI.Leijen as PP
import           Turtle                       hiding (strict, view)

import           Protolude                    hiding (FilePath, die, find, fold,
                                               (%))
-- !! This needs to be changed when local-configuration.nix updates its version !!
eclipseVersion = "4.6.2"

mrRepoUrl = "git://github.com/CIRB/vcsh_mr_template.git"

-- pinned user env pkgs
nixpkgsPinFile = ".config/nixpkgs/pin.nix"
envPackages = ["cicd-shell", "albert"]

data MrRepo
  = MrRepo
  { _path     :: LText
  , _checkout :: LText
  } deriving (Generic, Show)

data Console
  = Console
  { _color :: LText
  } deriving (Generic, Show)

data BoxConfig
  = BoxConfig
  { _userName        :: LText
  , _userEmail       :: LText
  , _repos           :: Vector LText
  , _eclipsePlugins  :: Bool
  , _wallpaper       :: LText
  , _console         :: Console
  , _additionalRepos :: Vector MrRepo
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

scriptEnv :: IO ScriptEnv
scriptEnv =
   ScriptEnv <$> Dhall.input auto "/vagrant/config/box"
             <*> home
  where
    auto ::  Interpret a => Type a
    auto = autoWith
      ( defaultInterpretOptions { fieldModifier = Text.Lazy.dropWhile (== '_') })

installPkKeys :: (MonadIO m, MonadReader ScriptEnv m) => m ()
installPkKeys = do
  printf "\nSynchronizing ssh keys\n"
  testdir "/vagrant/ssh-keys" >>= \case
    False -> die "ERROR: no ssh-keys directory found. User provisioning aborted."
    True -> do
      homedir <- asks (view homeDir)
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

installMrRepos :: (MonadIO m, MonadReader ScriptEnv m) => m ()
installMrRepos =  do
  printf "\nInstalling mr repos\n"
  homedir <- asks (view homeDir)
  add_rx <- asks $ view (boxConfig.additionalRepos)
  rx <- asks $ view (boxConfig.repos)
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
           ppFailure ("Unable to clone mr" <+> ppText url <> "\n")
           die "Aborting user configuration"
         ExitSuccess   -> ppSuccess ("Clone mr" <+> ppText url <> "\n")
    add_repo_to_mr rx = sh $ do
      r <- select (rx^..traverse)
      let
        path' = r^.path.strict
        checkout' = r^.checkout.strict
      proc "mr" [ "config"
                 , path'
                 , "checkout = " <> checkout'
                ] empty >>= \case
         ExitFailure _ -> do
           ppFailure ("Unable to add" <+> ppText checkout' <+> "to mr\n")
           die "Aborting user configuration"
         ExitSuccess   -> printf ("Add "%s%" to mr\n") checkout'
    activate_repos home_dir rx = sh $ do
      r <- select (rx^..traverse.strict)
      unless (Text.null r) $ do
        let link_target = format ("../available.d/"%s) r
            link_name = format (fp%"/.config/mr/config.d/"%s) home_dir r
        procs "ln" [ "-sf", link_target, link_name] empty
        printf ("Activate "%s%"\n") r

installDoc :: (MonadIO m, MonadReader ScriptEnv m) => m ()
installDoc = do
  inproc "curl" ["-s", "http://stash.cirb.lan/projects/CICD/repos/puppet-shared-scripts/raw/README.adoc?at=refs/heads/master"] empty
    & output "puppet.adoc"
  inproc "curl" ["-s", "http://stash.cirb.lan/projects/CICD/repos/cicd-shell/raw/README.adoc?at=refs/heads/master"] empty
    & output "cicd-shell.adoc"
  isFileEmpty "puppet.adoc" ||^ isFileEmpty "cicd-shell.adoc" >>= \case
    True -> ppFailure "cannot fetch extra documentation from stash: documentation not installed"
    False -> do
      exitcode <- shell "make doc > /dev/null" empty
      case exitcode of
        ExitFailure _ -> ppFailure "documentation not installed successfully.\n"
        ExitSuccess   -> do
          homedir <- asks (view homeDir)
          let docdir = homedir </> ".local/share/"
          mktree docdir
          proc "cp" ["-r", "doc", format fp docdir] empty
          ppSuccess "documentation\n"

installEclipsePlugins :: (MonadIO m, MonadReader ScriptEnv m) => m ()
installEclipsePlugins = do
    with_plugins <- asks $ view (boxConfig.eclipsePlugins)
    when with_plugins $ do
      install_plugin "org.eclipse.egit" "http://download.eclipse.org/releases/mars/" "org.eclipse.egit.feature.group"
      install_plugin "org.eclipse.m2e" "http://download.eclipse.org/releases/mars/" "org.eclipse.m2e.feature.feature.group"
  where
    install_plugin full_name repository installIU = do
      homedir <- ask $ view homeDir
      let localdir = homedir </> ".eclipse"
          installPath = localdir </> fromText ("org.eclipse.platform_" <> eclipseVersion)
          prefix_fp = installPath </> "plugins" </> fromText full_name
      not_installed <- testdir localdir >>= \case
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
          ExitFailure _ -> ppFailure ("Eclipse plugin" <+> ppText full_name <+> "won't installed\n")
          ExitSuccess -> ppSuccess ("Eclipse plugin" <+> ppText full_name <+> "\n")

configureGit :: (MonadIO m, MonadReader ScriptEnv m) => m ()
configureGit = do
  printf "Configuring git\n\n"
  user_name <- asks $ view (boxConfig.userName.strict)
  user_email <- asks $ view (boxConfig.userEmail.strict)
  unless (Text.null user_name) $ procs "git" [ "config", "--global", "user.name", user_name] empty
  unless (Text.null user_email) $ procs "git" [ "config", "--global", "user.email", user_email] empty

configureWallpaper :: (MonadIO m, MonadReader ScriptEnv m) => m ()
configureWallpaper = do
  printf "Configuring wallpaper\n\n"
  homedir <- asks (view homeDir)
  filename <- asks $ view (boxConfig.wallpaper.strict)
  let link_target = homedir </> ".wallpaper" </> fromText filename
      link_name = homedir </> ".wallpaper.jpg"
  procs "ln" [ "-sf"
             , format fp link_target
             , format fp link_name
             ] empty

configureConsole :: (MonadIO m, MonadReader ScriptEnv m) => m ()
configureConsole = do
  printf "Configuring console\n\n"
  homedir <- asks (view homeDir)
  color <- asks $ view (boxConfig.console.color.strict)
  let color_fp = homedir </> ".config/urxvt/themes"
      link_target = color_fp </> fromText color
      link_name = color_fp </> "default"
  procs "ln" [ "-sf"
             , format fp link_target
             , format fp link_name
             ] empty

installEnvPackages :: (MonadIO m, MonadReader ScriptEnv m) => [Text] -> m ()
installEnvPackages px = do
  homedir <- asks (view homeDir)
  sh $ do
      p <- select px
      proc "nix-env" [ "-i", p
                     , "-f" , format fp (homedir </> nixpkgsPinFile)
                     ] empty >>= \case
        ExitSuccess   -> ppSuccess $ ppText p <> "\n"
        ExitFailure _ -> ppFailure $ "enable to install" <+> ppText p <+> "\n"

main :: IO ()
main = do
  args <- getArgs
  System.hSetBuffering System.stdout System.LineBuffering
  actions <- case args of
    [] -> do
      printf "\n> Starting user configuration\n"
      pure [ installPkKeys
           , installMrRepos
           , configureGit
           , configureWallpaper
           , configureConsole
           , installEnvPackages envPackages
           , installDoc
           , installEclipsePlugins
           ]
    ["--sync"] -> do
      printf "\n> Sync user configuration\n"
      pure [ installPkKeys
           , installMrRepos
           , configureGit
           , configureWallpaper
           , configureConsole
           ]
    _ -> die "Unrecognized option. Exit."
  runReaderT (sequence_ actions) =<< scriptEnv
  printf "< User configuration completed\n"

-- UTILS
ppText = PP.text . Text.unpack

ppFailure :: MonadIO io => PP.Doc -> io ()
ppFailure msg = liftIO $ putDoc $ (red "FAILURE:" <+> msg) <> line

ppSuccess :: MonadIO io => PP.Doc -> io ()
ppSuccess msg = liftIO $ putDoc $ (dullgreen "Done with" <+> msg) <> line

isFileEmpty :: MonadIO io => FilePath -> io Bool
isFileEmpty path =
  fold (input path) Fold.null
