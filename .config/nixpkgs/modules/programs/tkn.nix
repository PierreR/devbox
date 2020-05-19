{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.tkn;
in

{
  options.programs.tkn = {
    enable = mkEnableOption "tekton CLI";
    version = mkOption {
      default = "0.6.0";
      type = types.str;
    };
    sha256 = mkOption {
      default = "1nrlwknplnvhyx5qw98l0pn7nd3p8dq5np5y5ylsd71jxf7vnxjy";
      type = types.str;
    };
  };
  config =
      mkIf cfg.enable {
        home.packages = [ pkgs.oc.tkn ];
      };
}
