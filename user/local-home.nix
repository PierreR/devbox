{ config, pkgs, ... }:
  
{
  
  home.packages = with pkgs; [
    # asciidoctor
    # atom
    # awscli
    # aws-iam-authenticator
    # bazel
    # bundix
    # cabal2nix
    # (import (builtins.fetchTarball "https://cachix.org/api/v1/install") {}).cachix
    # docker_compose
    # dnsmasq
    # du-dust
    # filebeat
    # firefox
    # geany
    # gitAndTools.tig
    # gnome3.nautilus
    # go2nix
    # gcc
    # (import (builtins.fetchTarball "https://github.com/hercules-ci/ghcide-nix/tarball/master") {}).ghcide-ghc865)
    # jetbrains.idea-community
    # jetbrains.idea-ultimate
    # haskellPackages.shake
    # kubectl
    # kubernetes-helm
    # jdk
    # jdk11
    # maven
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