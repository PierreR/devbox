{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.direnv;

in
{
  options = {
    profiles.direnv = {
      enable = mkEnableOption "direnv";
    };
  };
  config = mkIf cfg.enable {
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    home.file.".config/direnv/lib/nix.sh" = {
      text = "
: \${XDG_CACHE_HOME:=$HOME/.cache}
pwd_hash=$(echo -n $PWD | shasum | cut -d ' ' -f 1)
mkdir -p $XDG_CACHE_HOME/direnv/layouts
direnv_layout_dir=$XDG_CACHE_HOME/direnv/layouts/$pwd_hash
";
      executable = true;
    };
  };

}
