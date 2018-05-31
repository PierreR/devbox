let
  pkgs = import <nixpkgs> {};
  pinned = import ./nixpkgs/pin.nix;
  henv = pinned.haskellPackages.ghcWithPackages (p: with p; [dhall protolude turtle ]);
in
{
  # We create a 'shell' suitable for interpreting the script
  user = pkgs.stdenv.mkDerivation {
    name = "user";
    buildInputs = [
      henv
      pkgs.mr
      pinned.vcsh
      pkgs.rsync
      pkgs.curl
    ];
  };
}
