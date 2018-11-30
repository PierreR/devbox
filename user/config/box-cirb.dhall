{- HELP
Box configuration file
  userName        : Full user name e.g "John Doe" (used in git)
  userEmail       : Email address e.g "jdoe@cirb.brussels" (used in git)
  loginId         : LoginId is typically a username used by external services as a identification id.
                    The box just stores this value in an env variable called 'LOGINID' that can then be used by other programs.
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


{ userName =
    ""
, userEmail =
    ""
, loginId =
    (./shell.dhall).loginId
, eclipse =
    True
, wallpaper =
    "mountain.jpg"
, console =
    { color = "light" }
, mr =
    { config =
        [] : List Text
    , templateUrl =
        "git://github.com/CIRB/vcsh_mr_template.git"
    , repos =
        [ "nixpkgs-config.mr", "xmonad.vcsh" ]
    }
, nix-env =
    , "-f https://github.com/CIRB/cicd-shell/archive/v2.5.11.tar.gz"
    ]
}
