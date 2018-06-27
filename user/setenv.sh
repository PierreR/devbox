#! /usr/bin/env bash
set -e

/usr/bin/env time -f "Done after %e" echo "hello"
# !! This needs to be changed when local-configuration.nix updates its version !!
eclipseVersion="4.7.2"

mrRepoUrl="git://github.com/CIRB/vcsh_mr_template.git"

# pinned user env pkgs
nixpkgsPinFile='.config/nixpkgs/pin.nix'

# configFile='/vagrant/config/box.dhall'
# userName=
# userEmail=
# loginId=
# dhall-to-bash --declare repos <<< "${configFile}.repos"
# echo repos
# declare repos=
# repos           :: Vector Text
# eclipsePlugins  :: Bool
# wallpaper       :: Text
# console         :: Console
# additionalRepos :: Vector MrRepo
# envPackages     :: Vector Text
