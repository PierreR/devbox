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
  dhall_github = hghc.callCabal2nix "dhall" (pkgs.fetchFromGitHub {
    owner  = "Gabriel439";
    repo   = "Haskell-Dhall-Library";
    rev    = "505a786c6dd7dcc37e43f3cc96031d30028625be";
    sha256 = "1dsjy4czxcwh4gy7yjffzfrbb6bmnxbixf1sy8aqrbkavgmh8s29";
  }) {};
  henv = hghc.ghcWithPackages (p: with p; [dhall_github text turtle vector]);

in
pkgs.stdenv.mkDerivation {
  name = "devbox-release-userenv";
  buildInputs = [ henv ];
}
