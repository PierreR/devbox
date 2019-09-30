{- HELP
Box configuration file
  userName          : Full user name e.g "John Doe" (used in git)
  userEmail         : Email address e.g "jdoe@cirb.brussels" (used in git)
  loginId           : LoginId is typically a username used by external services as a identification id.
                      The box just stores this value in an env variable called 'LOGINID' that can then be used by other programs.
  eclipse           : Do you want to install a statically defined Eclipse version that is known to work
                      (see user/eclipse.sh for more detail)
  lorri             : Enable lorri (https://github.com/target/lorri/)
  appLauncherHotkey : Application launcher (Albert) hotkey.
  wallpaper         : An image file in ~/.wallpaper that will be used as wallpaper.
                      see https://github.com/CIRB/devbox-dotfiles/.wallpaper
  console.color     : A color configuration file in ~/.config/termite that can be used to provide a light or dark theme to the terminal.
  netw              : Name of the network interface to be displayed by Taffybar (to be changed if you use vmware workstation)
  mr.config         : List of additional personal mr repositories you might want to add to your mrconfig file.
                      Ex: config = [ ".config/vcsh/repo.d/local.git checkout='vcsh clone git@mygithub.com:PierreR/devbox-dotfiles.git local'"]
  mr.templateUrl    : Url of a mr_template repository to be cloned by vcsh. This repo describes a set of available pre-defined mr repositories.
  mr.repos          : List of repositories to activate from the available set defined above.
  nix-env           : List of specs for the nix-env --install command
-}

{ userName = ""
, userEmail = ""
, loginId = ""
, eclipse = False
, lorri = True
, appLauncherHotkey = "Ctrl+Space"
, wallpaper = "mountain.jpg"
, netw = "enp0s3"
, console = { color = "light" }
, mr =
    { config = [] : List Text
    , templateUrl = "ssh://git@stash.cirb.lan:7999/devb/dotfiles.git"
    , repos = [] : List Text
    }
, nix-env = [ "-f https://github.com/CIRB/cicd-shell/archive/v2.7.0.tar.gz" ]
}
