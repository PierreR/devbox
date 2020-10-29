{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.xmonad;
in

{
  options = {
    profiles.xmonad = {
      enable = mkEnableOption "Xmonad";
      wallpaper = mkOption {
        type = types.str;
      };
      appLauncherHotkey = mkOption {
        default = "Ctrl+Space";
        type = types.str;
      };
      netw = mkOption {
        default = "enp0s3";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    xsession = {
      enable = true;
      scriptPath = ".hm-xsession";
      windowManager.xmonad = {
        enable = true;
        haskellPackages = pkgs.desktop.haskellPackages;
        extraPackages =
          hpkgs: [
            hpkgs.xmonad-contrib
            hpkgs.xmonad-extras
            hpkgs.taffybar
          ];
      };
      pointerCursor = {
        name = "Vanilla-DMZ";
        package = pkgs.vanilla-dmz;
        size = 24;
      };
      initExtra = ''
        systemctl --user import-environment
        systemctl --user --no-block start albert.service
      '';
    };
    profiles.taffybar = {
      enable = true;
      netw = cfg.netw;
    };
    profiles.albert = {
      enable = true;
      hotkey = cfg.appLauncherHotkey;
    };
    profiles.wallpaper = {
      enable = true;
      fileName = cfg.wallpaper;
    };
    services.picom = {
      enable = true;
      backend = "xrender";
    };
    services.unclutter.enable = true;
  };
}
