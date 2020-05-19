{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.mr;
in

{
  options = {
    profiles.mr = {
      enable = mkEnableOption "mr";
      configExtra = mkOption {
        default = [];
        type = types.listOf types.lines;
        description = "Extra mr repositories to setup (aka mr config)";
      };
      repos = mkOption {
        default = [];
        type = types.listOf types.str;
        description = "List of pre-defined repos to enable";
      };
    };
  };

  config = mkIf cfg.enable (
    mkMerge [
      {
        home.file.".mrconfig".text = ''
          [DEFAULT]
          git_gc = git gc "$@"
          jobs = 5

          include = cat ~/.config/mr/config.d/*

          ${concatStrings (
          map (
            extra: ''
              ${extra}
            ''
          ) cfg.configExtra
        )}
        '';
      }
      (
        mkIf (cfg.repos != []) {
          home.file = map (
            repo: {
              target = ".config/mr/config.d/${repo}";
              source = builtins.toPath "${config.home.homeDirectory}/.config/mr/available.d/${repo}";
            }
          ) cfg.repos;
        }
      )
    ]
  );
}
