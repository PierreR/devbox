{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    # asciidoctor
    # atom
    # awscli
    # aws-iam-authenticator
    # bazel
    # bundix
    # cabal-install
    # cabal2nix
    # (import (builtins.fetchTarball "https://cachix.org/api/v1/install") {}).cachix
    # dhall-lsp-server
    # docker_compose
    # dnsmasq
    # du-dust
    # filebeat
    # firefox
    # gcc
    # geany
    # gitAndTools.tig
    # gnome3.nautilus
    # go2nix
    # graphviz
    # (import (builtins.fetchTarball "https://github.com/hercules-ci/ghcide-nix/tarball/master") {}).ghcide-ghc865)
    # jetbrains.idea-community
    # jetbrains.idea-ultimate
    # haskellPackages.shake
    # kubernetes-helm
    # jdk
    # jdk11
    # maven
    # nix-du
    # nix-prefetch-git
    # nodejs
    # nodePackages.tern
    # openssl
    # pandoc
    # parallel
    # parcellite
    # podman
    # python
    # skopeo
    # stack
    # stack2nix
    # sublime3
    # ruby
    # rustup
    # rxvt_unicode-with-plugins
    # taskwarrior
    # terraform
    # zeal
  ];
}