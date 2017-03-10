# Local customization that won't be overridden by vagrant provision
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (eclipses.eclipseWithPlugins {
       eclipse = eclipses.eclipse-sdk-46;
       plugins = [ ];
     })
    firefox
    gitAndTools.tig
    # atom
    # geany
    # gnome3.nautilus
    # pandoc
    # parcellite
  ];

}
