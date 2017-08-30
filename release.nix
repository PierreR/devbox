let
  pkgs = import <nixpkgs> {};
  pinned = import ./nixpkgs/pin.nix;
  henv = pinned.haskellPackages.ghcWithPackages (p: with p; [dhall protolude_0_2 turtle ]);
in
{
  # We create a 'shell' suitable for interpreting the script
  user = pkgs.stdenv.mkDerivation {
    name = "user";
    buildInputs = [
      henv
      pkgs.mr
      pkgs.vcsh
      pkgs.rsync
      pkgs.curl
    ];
  };
  # This is just to trigger all deps downloads in one place
  trigger = pkgs.stdenv.mkDerivation {
    name = "trigger";
    buildInputs = [
      henv
      pinned.cicd-shell
      pinned.albert
      pinned.haskellPackages.language-puppet
      pkgs.puppet-env
    ];
  };
}
