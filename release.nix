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
      pkgs.cicd-shell
    ];
  };
}
