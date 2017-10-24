{- HELP
Box configuration file
  userName        : Full user name e.g "John Doe" (used in git)
  userEmail       : Email address e.g "jdoe@cirb.brussels" (used in git)
  repos           : Git repos to activate; see https://github.com/CIRB/vcsh_mr_template/tree/master/.config/mr/available.d
  eclipsePlugins  : Download eclipse plugins such as egit or m2e ?
  wallpaper       : Devbox wallpaper, see https://github.com/CIRB/devbox-dotfiles/.wallpaper
  console         : Console configuration such as light or dark background
  additionalRepos : List of additional personal mr repositories you might want to add
                    mr repo is a record with two fields. e.g: { path     = "$HOME/.config/vcsh/repo.d/local.git"
                                                              , checkout = "vcsh clone git@github.com:PierreR/devbox-dotfiles.git local"
                                                              }
  envPackages    : List of packages to be installed in the user env and pinned with a specific nixpkgs pointer
-}

{ userName        = ""
, userEmail       = ""
, repos         = [ "nixpkgs-config.mr" -- don't remove
                  , "xmonad.vcsh"       -- don't remove
                  , "puppet-bos.mr"
                  ]
, eclipsePlugins  = True
, wallpaper       = "devbox.jpg"
, console         = { color = "light" }
, additionalRepos = [ ] : List { path : Text, checkout : Text }
, envPackages    = [ "cicd-shell"
                   , "albert"
                   , "vcsh"
                   ]
