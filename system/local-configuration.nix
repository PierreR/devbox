# Local customization that won't be overridden by vagrant provision
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (eclipses.eclipseWithPlugins {
       eclipse = eclipses.eclipse-sdk-46;
       plugins = with eclipses.plugins; [ yedit ];
     })
    firefox
    gitAndTools.tig
    gnome3.nautilus
    # atom
    # geany
    # pandoc
    # parcellite
  ];

}
