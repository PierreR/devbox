# Local customization that won't be overridden by vagrant provision
# To activate your changes, type 'nixreb' in a terminal after saving your file.
{ config, lib, pkgs, ... }:

{

  imports = [
    # ./desktop-tiling-configuration.nix
    # ./desktop-gnome-configuration.nix
    # ./desktop-kde-configuration.nix
  ];

}
