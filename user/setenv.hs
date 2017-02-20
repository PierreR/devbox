{-# LANGUAGE DeriveGeneric          #-}
{-# LANGUAGE FlexibleContexts       #-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE LambdaCase             #-}
{-# LANGUAGE MultiParamTypeClasses  #-}
{-# LANGUAGE OverloadedStrings      #-}
{-# LANGUAGE QuasiQuotes            #-}
{-# LANGUAGE StrictData             #-}
{-# LANGUAGE TemplateHaskell        #-}
{-# LANGUAGE TypeSynonymInstances   #-}

-- | This script assumes it is started from the ROOT_DIR of the devbox
module Main where

import qualified Control.Foldl                as Fold
import           Control.Lens                 hiding (noneOf)
import           Control.Monad.Reader
import qualified Data.Text                    as Text
import qualified Data.Text.Lazy
import           Data.Vector                  (Vector)
import           Dhall                        hiding (Text, input, text)
import qualified Dhall
import           Prelude                      hiding (FilePath)
import           Text.PrettyPrint.ANSI.Leijen (dullgreen, line, putDoc, red, (<+>))
import qualified Text.PrettyPrint.ANSI.Leijen as PP
import           Turtle                       hiding (strict, view)

-- !! This needs to be changed when local-configuration.nix updates its version !!
eclipseVersion = "4.6.0"

type LText = Data.Text.Lazy.Text

data AdConfig
  = AdConfig
  { adLoginId  :: LText
  , adPassword :: LText
  } deriving (Generic, Show)

makeLensesWith abbreviatedFields ''AdConfig

instance Interpret AdConfig

data BoxConfig
  = BoxConfig
  { boxUserName       :: LText
  , boxUserEmail      :: LText
  , boxUserStacks     :: Vector LText
  , boxEclipsePlugins :: Bool
  , boxGeppetto       :: Bool
  , boxMrRepoUrl      :: LText
  } deriving (Generic, Show)

makeLensesWith abbreviatedFields ''BoxConfig

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

adConfig :: MonadIO m => m AdConfig
adConfig = liftIO $ Dhall.input auto "/vagrant/config/ad"

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
  mr_url <- asks $ view (boxConfig.mrRepoUrl.strict)
  stacks <- asks $ view (boxConfig.userStacks)
  bootstrap <- not <$> testfile (homedir </> ".mrconfig")
  when bootstrap $ clone_mr mr_url
  activate_stacks homedir stacks
  let mr_args = [ "-d", format fp homedir
                , "up", "-q"
                ]
  proc "mr" (if bootstrap then "-f" : mr_args else mr_args) empty >>= \case
    ExitFailure _ -> ppFailure "Unable to update all mr repositories\n\n"
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
    activate_stacks home_dir stacks = sh $ do
      stack <- select (stacks^..traverse.strict) :: Shell Text
      unless (Text.null stack) $ do
        let mr_file = format ("puppet-"%s%".mr") stack
            link_target = format ("../available.d/"%s) mr_file
            link_name = format (fp%"/.config/mr/config.d/"%s) home_dir mr_file
        printf ("Activate "%s%"\n") mr_file
        procs "ln" [ "-sf", link_target, link_name] empty

installDoc :: (MonadIO m, MonadReader ScriptEnv m) => m ()
installDoc = do
  inproc "curl" ["-s", "http://stash.cirb.lan/projects/CICD/repos/puppet-shared-scripts/raw/README.adoc?at=refs/heads/master"] empty
    & output "puppet.adoc"
  inproc "curl" ["-s", "http://stash.cirb.lan/projects/CICD/repos/cicd-shell/raw/README.adoc?at=refs/heads/master"] empty
    & output "cicd-shell.adoc"
  exitcode <- shell "make doc > /dev/null" empty
  case exitcode of
    ExitFailure _ -> ppFailure "documentation not installed successfully.\n"
    ExitSuccess   -> do
      homedir <- asks (view homeDir)
      let docdir = homedir </> ".local/share/doc"
      mktree docdir
      cp "./doc/devbox.html" (docdir </> "devbox.html")
      cp "doc/devbox.pdf" (docdir </> "devbox.pdf")
      ppSuccess "documentation\n"


installNixPkgsFiles :: (MonadIO m, MonadReader ScriptEnv m) => m ()
installNixPkgsFiles = do
  homedir <- asks (view homeDir)
  printf "\nInstalling nixpkgs local files\n"
  let nixpkgsdir = homedir </> ".nixpkgs/"
  found_dir <- testdir nixpkgsdir; unless found_dir $ mkdir nixpkgsdir
  cp "user/config.nix" (nixpkgsdir </> "config.nix")
  procs "rsync" [ "-r"
                , "user/pkgs"
                , format fp (homedir </> ".nixpkgs/")] empty

installEclipsePlugins :: (MonadIO m, MonadReader ScriptEnv m) => m ()
installEclipsePlugins = do
    with_plugins <- asks $ view (boxConfig.eclipsePlugins)
    with_geppetto <- asks $ view (boxConfig.geppetto)
    when with_plugins $ do
      install_plugin "org.eclipse.egit" "http://download.eclipse.org/releases/mars/" "org.eclipse.egit.feature.group"
      install_plugin "org.eclipse.m2e" "http://download.eclipse.org/releases/mars/" "org.eclipse.m2e.feature.feature.group"
    when with_geppetto $
      install_plugin "com.puppetlabs.geppetto" "http://geppetto-updates.puppetlabs.com/4.x" "com.puppetlabs.geppetto.feature.group"
  where
    install_plugin full_name repository installIU = do
      homedir <- ask $ view homeDir
      let installPath = homedir </> fromText (".eclipse/org.eclipse.platform_" <> eclipseVersion)
          prefix_fp = installPath </> "plugins" </> fromText full_name
      not_installed <- fold (find (prefix (text (format fp prefix_fp))) installPath) Fold.null
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
  printf "\nConfiguring git\n"
  user_name <- asks $ view (boxConfig.userName.strict)
  user_email <- asks $ view (boxConfig.userEmail.strict)
  unless (Text.null user_name) $ procs "git" [ "config", "--global", "user.name", user_name] empty
  unless (Text.null user_email) $ procs "git" [ "config", "--global", "user.email", user_email] empty

installCicdShell :: (MonadIO m, MonadReader ScriptEnv m) => m ()
installCicdShell = do
  -- we currently copy the AD id & pwd into the home of the box
  -- In later versions, such management would go in the CICD shell project
  homedir <- asks (view homeDir)
  ad <- adConfig
  let
    usr_id = unsafeTextToLine $ ad^.loginId.strict
    usr_pwd = unsafeTextToLine $ ad^.password.strict
  output (homedir </> ".user_id") $ pure usr_id
  output (homedir </> ".user_pwd") $ pure usr_pwd
  shell "nix-env -f '<nixpkgs>' -i cicd-shell" empty >>= \case
    ExitSuccess   -> ppSuccess "cicd shell\n"
    ExitFailure _ -> ppFailure "enable to install the cicd shell\n"

main :: IO ()
main = do
  printf "\n> Starting user configuration\n"
  runReaderT (sequence_ [ installPkKeys
                        , configureGit
                        , installNixPkgsFiles
                        , installMrRepos
                        , installEclipsePlugins
                        , installCicdShell
                        , installDoc
                        ]) =<< scriptEnv
  printf "< User configuration completed\n"


-- UTILS
ppText = PP.text . Text.unpack

ppFailure :: MonadIO m => PP.Doc -> m ()
ppFailure msg = liftIO $ putDoc $ (red "FAILURE:" <+> msg) <> line

ppSuccess :: MonadIO m => PP.Doc -> m ()
ppSuccess msg = liftIO $ putDoc $ (dullgreen "Done with" <+> msg) <> line
