# Local customization that won't be overridden by vagrant provision
# To activate your changes, type 'updateSystem' in a terminal after saving your file.
{ config, lib, pkgs, ... }:

{

  # Only one desktop should be uncommented.
  # Feel free to try another one.
  imports = [
    # ./puppetdb-dns.nix
    ./desktop-tiling-configuration.nix
    # ./desktop-gnome-configuration.nix
    # ./desktop-kde-configuration.nix
  ];

  environment.extraInit = ''
    export _JAVA_AWT_WM_NONREPARENTING=1 # Fix intelliJ blank popup
    export DESKTOP_SESSION=gnome
    export BROWSER=google-chrome-stable
  '';
  environment.systemPackages = with pkgs; [
    # ansible
    # asciidoctor
    # atom
    # bazel
    # bundix
    # cabal2nix
    # dnsmasq
    docker
    # docker_compose
    # filebeat
    # firefox
    # geany
    # gitAndTools.tig
    gnome3.nautilus
    # go2nix
    # gcc
    # ghc
    google-chrome
    gnupg
    # gnome3.file-roller
    # jetbrains.idea-community
    # jetbrains.idea-ultimate
    # haskellPackages.hlint
    # haskellPackages.cabal-plan
    # haskellPackages.shake
    # haskellPackages.stylish-haskell
    # jdk
    # jdk11
    # kubectl
    # maven
    # nix-prefetch-git
    # nodejs
    # nodePackages.tern
    # openssl
    # openshift
    # pandoc
    # parallel
    # parcellite
    # podman
    # python
    # ruby
    # rustup
    # rxvt_unicode-with-plugins
    # shellcheck
    # skopeo
    # stack
    # stack2nix
    # sublime3
    # taskwarrior
    # terraform
    # tmux
    vscode
    # zeal
  ];

  virtualisation.docker.enable = true;
  users.users.vagrant.extraGroups = [ "docker" ];

  # Enable the puppetdb dns service
  # services.puppetdb-dns.enable = true;

  # Postgresql server
  # services.postgresql = {
  #   enable = true;
  # #  authentication = ''
  # #    local saltstack salt trust
  # #  '';
  # #   initialScript = /vagrant/initdb.sql;
  # };

  # Salt server
  # networking.extraHosts = ''
  #   127.0.0.1 salt
  # '';
  # services.salt.master = {
  #   enable = true;
  # };
  # services.salt.minion.enable = true;

  # Elasticsearch with Kibana
  # services.rsyslogd.enable = true;
  # services.elasticsearch = {
  #   enable = true;
  #   package = pkgs.elasticsearch6;
  # };
  # services.kibana = {
  #   enable = true;
  #   package = pkgs.kibana6;
  # };

  # Kubernetes labs
  # services.kubernetes = {
  #   roles = ["master" "node"];
  #   addons.dashboard.enable = true;
  # };

  # Activate direnv for zsh
  # programs = {
  #   zsh.interactiveShellInit = ''
  #     eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
  #   '';
  # };
}
