{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.zsh;
in

{
  options = {
    profiles.zsh = {
      loginId = mkOption {
        default = "";
        type = types.str;
      };
      sharedDir = mkOption {
        default = "/vagrant";
        type = types.str;
      };
      zshTheme = mkOption {
        default = "lambda-mod";
        type = types.str;
      };
    };
  };
  config = {
    programs.zsh = {
      enable = true;
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
      shellAliases = {
        la = " ls -alh";
        ls = " ls --color=tty";
        ll = "ls -lh";
        duh = " du -h --max-depth=1";
        df = " df -h";
        ag = "ag --color-line-number=3";
        vi = "vim";
        chrome = "google-chrome-stable";
        see = "./bin/check_role.sh";
        heyaml = "./bin/eyaml.sh $@";
        fixlint = "./bin/fix-lint.sh";
        nixreb = "sudo nixos-rebuild switch";
        ldir = "ls -ladh (.*|*)(/,@)";
        lfile = "ls -lah *(.)";
      };
      initExtraBeforeCompInit = ''
      '';
      initExtra = ''
        source $(dirname $(which autojump))/../share/autojump/autojump.zsh
        path+="$HOME/.local/bin"
        # hot fix for https://github.com/NixOS/nixpkgs/issues/27587
        autoload -U compinit && compinit
      '';
      envExtra = ''
        export LOGINID='${cfg.loginId}'
        export DIRENV_WARN_TIMEOUT='60s'
      '';
    };
  };
}
