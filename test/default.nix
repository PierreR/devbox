let
  pinnedVersion = builtins.fromJSON (builtins.readFile ./.nixpkgs-version.json);
  pinnedPkgs = import (
    builtins.fetchGit {
      inherit (pinnedVersion) url rev;
    }
  ) {};
in

{ pkgs ? pinnedPkgs }:

  with pkgs;

  stdenv.mkDerivation rec {
    name = "env";
    env = buildEnv { name = name; paths = buildInputs; };
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup; ln -s $env $out
    '';
    buildInputs = [
      mr
      git
      rsync
      vcsh
      gnupg
      cacert
      shellcheck
      gitAndTools.pre-commit
    ];
  }
