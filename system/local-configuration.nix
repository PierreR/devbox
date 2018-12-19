# Local customization that won't be overridden by vagrant provision
# To activate your changes, type 'nixreb' in a terminal after saving your file.
{ config, lib, pkgs, ... }:

{

  # Only one desktop should be uncommented.
  # Feel free to try another one.
  imports = [
    # ./puppetdb-dns.nix
      ./desktop-tiling-configuration.nix
    # ./desktop-gnome-configuration.nix
    #./desktop-kde-configuration.nix
  ];

}
