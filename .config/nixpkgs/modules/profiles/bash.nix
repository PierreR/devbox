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
      historyControl = [ "erasedups" ];
      historyIgnore = [ "cd" ];
      shellAliases = alias;
      initExtra = ''
        path+="$HOME/.local/bin"
        GIT_PS1_SHOWUNTRACKEDFILES="show"
        GIT_PS1_SHOWDIRTYSTATE="show"
        source ~/.zsh_custom/fun.zsh
        PS1='\n\[\033[1;32m\]\w \[\033[0m\]\[\033[01;34m\]$(__git_ps1 " %s")\[\033[0m\]$(( test -d .git ) && echo "\n→ " || echo "→ ")'
      '';
    };
  };
}
