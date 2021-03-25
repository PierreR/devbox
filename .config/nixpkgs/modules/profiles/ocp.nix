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
        default = false;
        description = "Enable podman";
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      openshift-client
      oc.odo
      k8s.tkn
      k8s.helm
    ];

    programs.podman.enable = cfg.podman;

    programs.zsh.initExtra = ''
      # Ugly hack: oc completion does not seem to work out of the box with zsh
      source ${pkgs.openshift-client}/share/zsh/site-functions/_oc
    '';
  };
}
