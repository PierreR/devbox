# Local customization that won't be overridden by vagrant provision
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (eclipses.eclipseWithPlugins {
       eclipse = eclipses.eclipse-sdk-452;
       plugins = [ ];
     })
    # geany
  ];
}
