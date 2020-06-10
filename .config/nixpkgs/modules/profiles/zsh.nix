{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.zsh;
  alias = import ../assets/alias.nix;
in
{
  options = {
    profiles.zsh = {
      enable = mkEnableOption "zsh";
      zshTheme = mkOption {
        default = "simple";
        type = types.str;
      };
    };
  };
  config = {
    programs.zsh = {
      enable = cfg.enable;
      enableCompletion = true;
      enableAutosuggestions = false;
      history = {
        size = 80000;
        expireDuplicatesFirst = true;
        ignoreDups = true;
      };
      oh-my-zsh.enable = true;
      oh-my-zsh.custom = "$HOME/.zsh_custom";
      oh-my-zsh.theme = "${cfg.zshTheme}";
      oh-my-zsh.plugins = [ "cicd" ];
      shellAliases = alias // {
        ldir = "ls -ladh (.*|*)(/,@)";
        lfile = "ls -lah *(.)";
      };
      initExtraBeforeCompInit = ''
      '';
      initExtra = ''
        source $(dirname $(which autojump))/../share/autojump/autojump.zsh
        path+="$HOME/.local/bin"
        # hot fix for https://github.com/NixOS/nixpkgs/issues/27587
        autoload -Uz compinit && compinit
      '';
    };
  };
}
