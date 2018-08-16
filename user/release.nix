# You can build this repository using Nix by running:
#
#     $ nix build -f release.nix project
#
# You can run the builded cicd command in a nix shell with:
#     $ nix run -r release.nix project
#
let
  nixpkgs = builtins.fromJSON (builtins.readFile ./.nixpkgs.json);
  overlay = self: super:
    let
      hlib = super.haskell.lib;
      lib = super.lib;
      filter =  path: type:
                  type != "symlink" && baseNameOf path != ".stack-work"
                                    && baseNameOf path != "stack.yaml"
                                    && baseNameOf path != ".git";
    in
    {
      haskellPackages = super.haskellPackages.override {
        overrides = hself: hsuper: rec {
          devbox-user = hlib.overrideCabal
            ( hsuper.callPackage ./devbox-user.nix { })
            ( csuper: { src = builtins.path { name = "devbox-user"; inherit filter; path = csuper.src;};}
            );
        };
      };

     devbox-user = hlib.justStaticExecutables self.haskellPackages.devbox-user;
  };
  pkgs = import <nixpkgs> {};
  pinned = import (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgs.rev}.tar.gz";
      inherit (nixpkgs) sha256;
    }){ config = {}; overlays = [ overlay ];};

in
{
  project = pkgs.mkShell {
    name = "devbox-user-env";
    paths = [
      pinned.devbox-user
      pkgs.mr
      pinned.vcsh
      pkgs.rsync
      pkgs.curl
    ];
  };
}