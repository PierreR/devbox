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
    programs.bash.initExtra = ''
      source <(${pkgs.cicd-shell}/bin/cicd --bash-completion-script `which cicd`)
    '';
    home.packages = [ pkgs.cicd-shell ];
  };
}
