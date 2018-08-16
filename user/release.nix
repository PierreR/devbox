# You can run the user/setenv script with:
#
#     $ nix-shell -A shell -f release.nix --command 'setenv'
#
# or build the setenv executable with:
#     $ nix-build -A exec release.nix
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

  };
  pkgs = import <nixpkgs> {};
  pinned = import (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgs.rev}.tar.gz";
      inherit (nixpkgs) sha256;
    }){ config = {}; overlays = [ overlay ];};

in

rec {
  exec = pinned.haskell.lib.justStaticExecutables pinned.haskellPackages.devbox-user;
  shell = pkgs.mkShell {
    name = "devbox-user-env";
    buildInputs = [
      exec
      pkgs.mr
      pinned.vcsh
      pkgs.rsync
      pkgs.curl
    ];
  };
}