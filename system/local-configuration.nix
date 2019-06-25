# Local customization that won't be overridden by vagrant provision
# To activate your changes, type 'nixreb' in a terminal after saving your file.
{ config, lib, pkgs, ... }:

{

  imports = [
      ./desktop-tiling-configuration.nix
  ];

  environment.systemPackages = with pkgs; [
    paper-gtk-theme
    paper-icon-theme
  ];

  # Launch virtualbox from its UI and get the /vagrant shared folder
  # fileSystems."/vagrant" = {
  #   fsType = "vboxsf";
  #   device = "vagrant";
  #   options = [ "rw" ];
  # };

  # Launch vmware Workstation from its UI and get the /mnt shared folder
  # fileSystems."/vagrant" =
  # { device = ".host:/";
  #   fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
  #   options = [ "allow_other" "uid=1000" "gid=100" "auto_unmount" "defaults"];
  # };
}
