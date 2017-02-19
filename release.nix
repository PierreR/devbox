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
  henv = hghc.ghcWithPackages (p: with p; [dhall text turtle vector]);

in
pkgs.stdenv.mkDerivation {
  name = "devbox-release-userenv";
  buildInputs = [ henv ];
}
