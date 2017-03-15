let
  _pkgs = import <nixpkgs> { };

  _nixpkgs = builtins.fromJSON (builtins.readFile ./.nixpkgs.json);

  _src = _pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo  = "nixpkgs";
    inherit (_nixpkgs) rev sha256;
  };

  pkgs = import _src { };
  hghc = pkgs.haskellPackages;
  hlib = pkgs.haskell.lib;
  cicd-shell_git = hlib.dontCheck (hlib.dontHaddock(hghc.callCabal2nix "cicd-shell" (pkgs.fetchgit {
    url = "http://stash.cirb.lan/scm/cicd/cicd-shell.git";
    rev = "ea926b0a943fb5f275347217081b17e5c6db645c";
    sha256 = "00f41yv7df3hhzpbkrv520jfv0m8njmfcz59kdskdfw6kb59lh5p";
  }) {dhall = hghc.dhall_git;}));
  henv = hghc.ghcWithPackages (p: with p; [dhall_git protolude_git turtle ]);

in
{
  # We create an 'shell' suitable for interpreting the script
  user = pkgs.stdenv.mkDerivation {
    name = "user";
    buildInputs = [
      henv
      _pkgs.ruby
      _pkgs.asciidoctor
      _pkgs.mr
      _pkgs.rsync
      _pkgs.curl
    ];
  };
  cicd-shell = pkgs.buildEnv {
    name = "cicd-shell";
    paths = [
      cicd-shell_git
    ];
  };
}
