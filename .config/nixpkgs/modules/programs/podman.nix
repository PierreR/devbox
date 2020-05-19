{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.podman;
in
{
  options = {
    programs.podman = {
      enable = mkEnableOption "podman";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ slirp4netns podman ];
    xdg.configFile."containers/libpod.conf".text = ''
      image_default_transport = "docker://"
      runtime_path = ["${pkgs.runc}/bin/runc"]
      conmon_path = ["${pkgs.conmon}/bin/conmon"]
      cni_plugin_dir = ["${pkgs.cni-plugins}/bin/"]
      cgroup_manager = "systemd"
      cni_config_dir = "/etc/cni/net.d/"
      cni_default_network = "podman"
      # pause
      pause_image = "k8s.gcr.io/pause:3.1"
      pause_command = "/pause"
    '';

    xdg.configFile."containers/registries.conf".text = ''
      [registries.search]
      registries = ['docker.io', 'repository.irisnet.be', 'quay.io', 'registry.access.redhat.com']
    '';

    xdg.configFile."containers/policy.json".text = ''
      {
        "default": [
          { "type": "insecureAcceptAnything" }
        ]
      }
    '';
  };
}
