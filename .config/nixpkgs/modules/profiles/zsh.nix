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
      oh-my-zsh.theme = "lambda-mod";
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
      initExtra = ''
        source $(dirname $(which autojump))/../share/autojump/autojump.zsh
        source <(${pkgs.openshift}/bin/oc completion zsh)
        source <(${pkgs.openshift}/bin/kubectl completion zsh)
        path+="$HOME/.local/bin"
        export NIX_PATH=$NIX_PATH:nixpkgs-overlays=http://stash.cirb.lan/CICD/nixpkgs-overlays/archive/master.tar.gz
      '';
      envExtra = ''
        export LOGINID='${cfg.loginId}'
        export DIRENV_WARN_TIMEOUT='60s'
        export EDITOR='vim'
      '';
    };
  };
}
