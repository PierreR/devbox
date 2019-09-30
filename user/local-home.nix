{ config, pkgs, ... }:
  
{
  
  home.packages = with pkgs; [
    # ansible
    # asciidoctor
    # atom
    # bazel
    # bundix
    # cabal2nix
    # dnsmasq
    # awscli
    # aws-iam-authenticator
    # du-dust
    # docker_compose
    # filebeat
    # firefox
    # geany
    # gitAndTools.tig
    # gnome3.nautilus
    # go2nix
    # gcc
    # jetbrains.idea-community
    # jetbrains.idea-ultimate
    # haskellPackages.shake
    # kubectl
    # kubernetes-helm
    # jdk
    # jdk11
    # maven
    # nodejs
    # nodePackages.tern
    # openssl
    # openshift
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