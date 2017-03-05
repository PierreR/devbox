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
  protolude_git = hghc.callCabal2nix "protolude" (pkgs.fetchFromGitHub {
    owner  = "pierrer";
    repo   = "protolude";
    rev = "03639fd5bb71297a61a4f9fd523a87fd40b9d280";
    sha256 = "1h1b8rmr1qz7xvdaf2blj2z13zsqkj9a6zmql70b4hn38digddk8";
  }) {};
  dhall_git = hghc.callCabal2nix "dhall" (pkgs.fetchFromGitHub {
    owner  = "Gabriel439";
    repo   = "Haskell-Dhall-Library";
    rev    = "11ceab1dfeb9ed9a25dab717b4fe24ffaf7d320e";
    sha256 = "00iz2albmj3iw8sdj2idf1y4vgfjfliv7xcxbqgmb3ggp7n7wf6a";
  }) {};
  henv = hghc.ghcWithPackages (p: with p; [dhall_git protolude_git turtle ]);

in
pkgs.stdenv.mkDerivation {
    name = "devbox-release-userenv";
    buildInputs = [
      henv
      pkgs.asciidoctor
      pkgs.mr
      pkgs.ghc
      pkgs.rsync
      pkgs.curl
    ];
}
