{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.ocp;
in

{
  options = {
    profiles.ocp = {
      enable = mkEnableOption "openshift container platform v4.x";
      odo = mkOption {
        default = true;
        description = "Enable odo";
        type = types.bool;
      };
      tkn = mkOption {
        default = true;
        description = "Enable tekton cli";
        type = types.bool;
      };
      podman = mkOption {
        default = true;
        description = "Enable podman";
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      buildah
      oc.odo
      oc.tkn
    ];
    programs.podman.enable = cfg.podman;
  };
}
