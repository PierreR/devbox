# Local customization that won't be overridden by vagrant provision
# To activate your changes, type 'nixreb' in a terminal after saving your file.
{ config, lib, pkgs, ... }:

{

  # Only one desktop should be uncommented.
  # Feel free to try another one.
  imports = [
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
    asciidoctor
    # atom
    bind
    # bundix
    # cabal2nix
    # dnsmasq
    # docker_compose
    # firefox
    # geany
    # gitAndTools.tig
    gnome3.nautilus
    # go2nix
    google-chrome
    # gnome3.file-roller
    # jetbrains.idea-community
    # jetbrains.idea-ultimate
    haskellPackages.shake
    # haskellPackages.xmobar
    jdk
    # maven
    # nix-prefetch-git
    # nodejs
    # nodePackages.tern
    # openssl
    # pandoc
    parallel
    # parcellite
    python
    # taskwarrior
    # terraform
    # ruby
    # rxvt_unicode-with-plugins
    shellcheck
    # sublime3
    # tmux
    vscode
    # zeal
  ];

  # Launch virtualbox from its UI and get the /vagrant shared folder
  fileSystems."/vagrant" = {
    fsType = "vboxsf";
    device = "vagrant";
    options = [ "rw" ];
  };

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

}
