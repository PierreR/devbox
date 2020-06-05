{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.bash;
  alias = import ../assets/alias.nix;
in
{
  options = {
    profiles.bash = {
      enable = mkEnableOption "bash";
    };
  };
  config = {
    programs.bash = {
      enable = cfg.enable;
      enableAutojump = true;
      historyControl = [ "erasedups" ];
      historyIgnore = [ "cd" ];
      shellAliases = alias;
      initExtra = ''
        path+="$HOME/.local/bin"
      '';
    };
  };
}
