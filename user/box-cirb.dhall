{- HELP
Box configuration file
  userName          : Full user name e.g "John Doe" (used in git)
  userEmail         : Email address e.g "jdoe@cirb.brussels" (used in git)
  loginId           : LoginId is typically a username used by external services as a identification id.
                      The box just stores this value in an env variable called 'LOGINID' that can then be used by other programs.
  eclipse           : Do you want to install a statically defined Eclipse version that is known to work.
  defaultStacks     : List of stack to use by default for tools such as the cicd shell.
  lorri             : Enable lorri (https://github.com/target/lorri/)
  appLauncherHotkey : Application launcher (Albert) hotkey.
  wallpaper         : An image file in ~/.wallpaper that will be used as wallpaper.
                      see https://github.com/CIRB/dotfiles/.wallpaper
  console.color     : A color configuration file in ~/.config/termite that can be used to provide a light or dark theme to the terminal.
  mr.config         : List of additional personal mr repositories you might want to add to your mrconfig file.
                      Ex: config = [ "projects/pi3r/notebook checkout='git clone git@mygithub.com:PierreR/notebook.git notebook'"]
  mr.repos          : List of repositories to activate from the available set defined above.
  nix-env           : List of specs for the nix-env --install command
  netw              : Name of the network interface to be displayed by Taffybar (to be changed if you use vmware workstation)
  dotfilesUrl       : Url of the user dotfiles repository. This repo will drive the whole user configuration.
-}

{ userName = ""
, userEmail = ""
, loginId = ""
, defaultStacks = [ "ci" ]
, eclipse = False
, lorri = True
, appLauncherHotkey = "Ctrl+Space"
, wallpaper = "mountain.jpg"
, console = { color = "light" }
, mr =
    { config = [] : List Text
    , repos = [] : List Text
    }
, nix-env = [ "-f https://github.com/CIRB/cicd-shell/archive/v2.7.0.tar.gz" ]
, netw = "enp0s3"
, dotfilesUrl = "http://stash.cirb.lan/scm/devb/dotfiles.git"
}