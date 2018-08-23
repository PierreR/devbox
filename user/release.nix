# You can run the user/setenv script with:
#
#     $ nix-shell -A shell -f release.nix --command 'setenv'
#
# or build the setenv executable with:
#     $ nix-build -A exec release.nix
#
let
  pkgs = import <nixpkgs> {};
  pinned = import ./share/pin.nix {};

  filter =  path: type:
    type != "symlink" && baseNameOf path != ".stack-work"
                      && baseNameOf path != "stack.yaml"
                      && baseNameOf path != ".git";
  devbox-user = pinned.haskell.lib.dontHaddock
    ( pinned.haskellPackages.callCabal2nix
        "devbox-user"
        (builtins.path { name = "devbox-user"; inherit filter; path = ./.; } )
        { }
    );
in

rec {
  exec = pinned.haskell.lib.justStaticExecutables devbox-user;
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
