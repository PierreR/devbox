{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.cicd;
in

{
  options.programs.cicd = {
    enable = mkEnableOption "CICD shell";
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.cicd-shell ];
  };
}
