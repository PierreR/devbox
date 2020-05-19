{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.odo;
in

{
  options.programs.odo = {
    enable = mkEnableOption "odo";
    version = mkOption {
      default = "v1.0.0";
      type = types.str;
    };
    sha256 = mkOption {
      default = "01iz0kjpvd55wh4q6d1siqhl66zhl8ig4k3xk3ga5xjap0274dqs";
      type = types.str;
    };
  };
  config =
      mkIf cfg.enable {
        home.packages = [ pkgs.oc.odo ];
      };
}
