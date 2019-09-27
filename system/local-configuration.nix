# Local customization that won't be overridden by vagrant provision
# To activate your changes, type 'updateSystem' in a terminal after saving your file.
{ config, lib, pkgs, ... }:

{

  imports = [
    ./lorri.nix
  ];

  environment.systemPackages = with pkgs; [
    docker
    google-chrome
    openshift
    shellcheck
    # tmux
    vscode
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
