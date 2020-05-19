{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.eclipse;

in

{
  options = {
    profiles.eclipse = {
      enable = mkEnableOption "Eclipse";
    };
  };

  config = mkIf cfg.enable {
    programs.eclipse = {
      enable = true;
      enableLombok = true;
      plugins = with pkgs.eclipses.plugins; [
        jdt
        spotbugs
        testng
        yedit
      ];
    };
  };
}
