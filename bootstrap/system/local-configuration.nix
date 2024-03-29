# Local optional/advanded customization.
# This file is only useful for configuring package/service at the system level.
# Prefer user customization in ROOT_DIR/local-home.nix as much as possible.
# To activate your changes, type 'updateSystem' in a terminal after saving your file.
{ config, lib, pkgs, ... }:

{
  users.users.vagrant.shell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
  ];


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
}
