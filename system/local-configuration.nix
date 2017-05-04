# Local customization that won't be overridden by vagrant provision
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # atom
    (eclipses.eclipseWithPlugins {
       eclipse = eclipses.eclipse-sdk-46;
       plugins = with eclipses.plugins; [ jdt yedit testng geppetto ];
     })
    firefox
    # geany
    gitAndTools.tig
    gnome3.nautilus
    # gnome3.file-roller
    # idea.idea-community
    # idea.idea-ultimate
    # jdk
    # maven
    # pandoc
    # parcellite
  ];

  # Uncomment these lines if you want to launch virtualbox from its UI
  #fileSystems."/vagrant" = {
  #  fsType = "vboxsf";
  #  device = "vagrant";
  #  options = [ "rw" ];
  #};

}
