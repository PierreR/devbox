{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.wallpaper;

in

{
  options = {
    profiles.wallpaper = {
      enable = mkEnableOption "Wallpaper";
      fileName = mkOption {
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.wallpaper = {
      Unit = {
        Description = "Wallpaper service";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.feh}/bin/feh --bg-scale ${config.home.homeDirectory}/.wallpaper/${cfg.fileName}";

      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
