{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.albert;
in

{
  options = {
    profiles.albert = {
      enable = mkEnableOption "Albert";
      hotkey = mkOption {
        default = "Ctrl+Space";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {

    home.packages = [ pkgs.albert ];

    home.file = {

      ".config/albert/albert.conf".text = ''
        [General]
        alfred_note_shown=true
        alwaysOnTop=true
        clearOnHide=false
        displayIcons=true
        displayScrollbar=false
        displayShadow=false
        hideOnClose=false
        hideOnFocusLoss=true
        hotkey=${cfg.hotkey}
        itemCount=5
        showCentered=true
        showTray=false
        standsalone_note_shown=true
        telemetry=false
        terminal=termite -e
        theme=Numix

        [org.albert.extension.applications]
        enabled=true

        [org.albert.extension.chromebookmarks]
        enabled=false

        [org.albert.extension.files]
        enabled=false

        [org.albert.extension.system]
        enabled=true
        reboot=sudo systemctl reboot
        shutdown=sudo systemctl poweroff

        [org.albert.extension.websearch]
        enabled=false

        [org.albert.frontend.widgetboxmodel]
        alwaysOnTop=true
        clearOnHide=false
        displayIcons=true
        displayScrollbar=false
        displayShadow=false
        hideOnClose=false
        hideOnFocusLoss=true
        showCentered=true
        theme=Numix

      '';

      ".config/albert/last_used_version".text = ''
        0.17.2

      '';

    };

    systemd.user.services.albert = {
      Unit = {
        Description = "Albert service";
      };
      Service = {
        ExecStart = "${pkgs.albert}/bin/albert";
        Environment = "XDG_CURRENT_DESKTOP=";
        # Restart = "on-failure";
        # RestartSec = 15;
      };
    };
  };
}
