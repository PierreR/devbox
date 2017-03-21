let
  pkgs = import <nixpkgs> { };
  henv = pkgs.haskellPackages.ghcWithPackages (p: with p; [dhall_git protolude_git turtle ]);
in
{
  # We create a 'shell' suitable for interpreting the script
  user = pkgs.stdenv.mkDerivation {
    name = "user";
    buildInputs = [
      henv
      pkgs.ruby
      pkgs.asciidoctor
      pkgs.mr
      pkgs.rsync
      pkgs.curl
    ];
  };
}
