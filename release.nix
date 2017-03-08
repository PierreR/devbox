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
  hlib = pkgs.haskell.lib;
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

  cicd-shell_git = hlib.dontCheck (hlib.dontHaddock(hghc.callCabal2nix "cicd-shell" (pkgs.fetchgit {
    url = "http://stash.cirb.lan/scm/cicd/cicd-shell.git";
    rev = "d7833d37c424d1451c103a24a92d28bc8b79322b";
    sha256 = "0qhi21905k17wvpn1smps4g5h82br20nps68hbijkr3h49yq2662";
  }) {dhall = dhall_git;}));
  henv = hghc.ghcWithPackages (p: with p; [dhall_git protolude_git turtle ]);

in
{
  # We create an 'shell' suitable for interpreting the script
  user = pkgs.stdenv.mkDerivation {
    name = "user";
    buildInputs = [
      henv
      pkgs.asciidoctor
      pkgs.mr
      pkgs.ghc
      pkgs.rsync
      pkgs.curl
    ];
  };
  cicd-shell = pkgs.buildEnv {
    name = "cicd-shell";
    paths = [
      cicd-shell_git
      # pkgs.pepper
    ];
  };
}
