let
  bootstrap = import <nixpkgs> { };

  nixpkgs = builtins.fromJSON (builtins.readFile ./.nixpkgs.json);

  src = bootstrap.fetchFromGitHub {
    owner = "NixOS";
    repo  = "nixpkgs";
    inherit (nixpkgs) rev sha256;
  };

  pkgs = import src { };
  hghc = pkgs.haskellPackages;
  dhall_lens = hghc.callCabal2nix "dhall" (pkgs.fetchFromGitHub {
    owner  = "Gabriel439";
    repo   = "Haskell-Dhall-Library";
    rev    = "c4aab8d1fc0824e92f18a0cadf2c0a6066b18b3a";
    sha256 = "0c0jzrvcjqr2a113j12mb5q1lvf30fsmany4rycix683ma2q07sq";
  }) {};
  henv = hghc.ghcWithPackages (p: with p; [dhall_lens text turtle vector]);

in
pkgs.stdenv.mkDerivation {
  name = "devbox-release-userenv";
  buildInputs = [ henv ];
}
