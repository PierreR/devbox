{- HELP
Box configuration file
  userName        : Full user name e.g "John Doe" (used in git)
  userEmail       : Email address e.g "jdoe@cirb.brussels" (used in git)
  loginId         : LoginId is typically a username used by external services as a identification id.
                    The box just stores this value in an env variable called 'LOGINID' that can then be used by other programs.
  mountDir        : ROOT_DIR folder mount point. Location of a folder mounted within your host to hold external files.
                    Typically the guest location of a windows shared folder or a usb device.
  sshkeysDir      : The ssh-keys folder path. All keys in that directory will be synchronized within your $HOME/.ssh folder
  eclipse         : Do you want to install a statically defined Eclipse version that is known to work
                    (see user/eclipse.sh for more detail)
  wallpaper       : An image file in ~/.wallpaper that will be used as wallpaper.
                    see https://github.com/CIRB/devbox-dotfiles/.wallpaper
  console.color   : A color configuration file in ~/.config/termite that can be used to provide a light or dark theme to the terminal.
  mr.config       : List of additional personal mr repositories you might want to add to your mrconfig file.
  mr.templateUrl  : Url of a mr_template repository to be cloned by vcsh. This repo describes a set of available pre-defined mr repositories.
  mr.repos        : List of repositories to activate from the available set defined above.
  nix-env         : List of specs for the nix-env --install command
-}

let mountDir = "/vagrant"

in  { userName =
        ""
    , userEmail =
        ""
    , loginId =
        ""
    , mountDir =
        "${mountDir}"
    , sshkeysDir =
        "${mountDir}/ssh-keys"
    , eclipse =
        False
    , wallpaper =
        "mountain.jpg"
    , console =
        { color = "light" }
    , mr =
        { config = [] : List Text, templateUrl = "", repos = [] : List Text }
    , nix-env =
        [] : List Text
    }
