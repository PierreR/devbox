{ config, lib, pkgs, ... }:

with lib;
let cfg = config.profiles.gpg;
in {
  options = {
    profiles.gpg = {
      enable = mkEnableOption "gpg";
    };
  };
  config = mkIf cfg.enable {
    programs.gpg.enable = true;
    services = {
      gpg-agent = {
        enable = true;
        enableSshSupport = true;
        defaultCacheTtlSsh = 7200;
        pinentryFlavor = "curses";
      };
    };
  };
}
