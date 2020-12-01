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
      enableCompletion = mkOption {
        default = false;
        type = types.bool;
      };
      enableAutosuggestions = mkOption {
        default = false;
        type = types.bool;
      };
    };
  };
  config = {
    programs.zsh = {
      enable = cfg.enable;
      enableCompletion = cfg.enableCompletion;
      enableAutosuggestions = cfg.enableAutosuggestions;
      history = {
        size = 80000;
        expireDuplicatesFirst = true;
        ignoreDups = true;
      };
      oh-my-zsh.enable = true;
      oh-my-zsh.custom = "$HOME/.zsh_custom";
      oh-my-zsh.theme = "${cfg.zshTheme}";
      oh-my-zsh.plugins = [ "cicd" "git" "git-extras" ];
      shellAliases = alias // {
        ldir = "ls -ladh (.*|*)(/,@)";
        lfile = "ls -lah *(.)";
      };
      initExtraBeforeCompInit = ''
      '';
      initExtra = ''
        # source $(dirname $(which autojump))/../share/autojump/autojump.zsh
        path+="$HOME/.local/bin"
        # hot fix for https://github.com/NixOS/nixpkgs/issues/27587
        autoload -Uz compinit && compinit

        #Load custom p10k config from /vagrant folder
        if [ -e /vagrant/p10k.zsh ]; then
           cp /vagrant/p10k.zsh $HOME/.zsh_custom/p10k.zsh
        fi
        ln -sf  $HOME/.zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme $HOME/.zsh_custom/themes/
      '';
      localVariables = {
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=#8c8c8c";
      };
      plugins = [
        {
          name = "zsh-completions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-completions";
            rev = "922eee0706acb111e9678ac62ee77801941d6df2";
            sha256 = "04skzxv8j06f1snsx62qnca5f2183w0wfs5kz78rs8hkcyd6g89w";
          };
        }
        {
          name = "powerlevel10k";
          src = pkgs.fetchFromGitHub {
            owner = "romkatv";
            repo = "powerlevel10k";
            rev = "v1.14.3";
            sha256 = "073d9hlf6x1nq63mzpywc1b8cljbm1dd8qr07fdf0hsk2fcjiqg7";
         };
       }
      ];
    };
  };
}
