{- HELP
Box configuration file
  userName                    : Full user name e.g "John Doe" (used in git)
  userEmail                   : Email address e.g "jdoe@cirb.brussels" (used in git)
  loginId                     : LoginId is typically a username used by external services as a identification id.
                                The box just stores this value in an env variable called 'LOGINID' that can then be used by other programs.
  defaultUI.enable            : Enable the defaul  defaultUI: a minimal tiling windowManager
                                Set the flag to False if you want to replace the tiling  defaultUI with a desktopManager such as Gnome, ...
  defaultUI.appLauncherHotkey : Application launcher (Albert) hotkey.
  defaultUI.wallpaper         : An image file in ~/.wallpaper that will be used as wallpaper.
                                see https://github.com/CIRB/dotfiles/.wallpaper
  defaultUI.netw              : Name of the network interface to be displayed by Taffybar (to be changed if you use vmware workstation)
  vscode.enable               : Enable vscode configuration via the home-manager
  vscode.manageExtension      : Manage vscode via the home-manager
  eclipse                     : Do you want to install a statically defined Eclipse version that is known to work.
  defaultStacks               : List of stack to use by default for tools such as the cicd shell.
  zsh.theme                    : Select zsh theme from ~/.zsh_custom/themes (ex: "lambda-mod" or "powerlevel10k")
  zsh.enableCompletion         : Optionnal : Enable completion with zsh
  zsh.enableAutosuggestions    : Optionnal : Enable zsh Autosuggestion
  console.cterm               : Change vim cursor line text font : italic,bold,underline, ... (optionnal)
  console.ctermbg             : Set vim cursor line color. (optionnal)
  mr.config                   : List of additional personal mr repositories you might want to add to your mrconfig file.
                                Ex: config = [ "[projects/pi3r/notebook]\ncheckout=git clone git@mygithub.com:PierreR/notebook.git" ]
  mr.repos                    : List of repositories to activate from the available set defined above.
-}

{ userName = ""
, userEmail = ""
, loginId = ""
, defaultUI =
    { enable = True
    , appLauncherHotkey = "Ctrl+Space"
    , netw = "enp0s3"
    , wallpaper = "mountain.jpg"
    }
, defaultStacks = [ "ci" ]
, vscode =
  { enable = True
  , manageExtension = False
  }
, cicd-shell = False
, eclipse = False
, ocp = False
, zsh.theme = "simple"
, mr =
    { config = [] : List Text
    , repos = [] : List Text
    }
}
