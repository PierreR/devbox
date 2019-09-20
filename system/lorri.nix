{ pkgs, ... }:

let
  sources = import ./nix/sources.nix;
  lorri = import sources.lorri {};
in
{
  systemd.user.sockets.lorri = {
    description = "lorri build daemon";
    listenStreams = [ "%t/lorri/daemon.socket" ];
    wantedBy = [ "sockets.target" ];
  };

  systemd.user.services.lorri = {
    description = "lorri build daemon";
    documentation = [ "https://github.com/target/lorri" ];
    requires = [ "lorri.socket" ];
    after = [ "lorri.socket" ];
    unitConfig = {
      ConditionUser = "!@system";
      RefuseManualStart = true;
    };

    serviceConfig = {
      ExecStart = "${lorri}/bin/lorri daemon";
      PrivateTmp = true;
      ProtectSystem = "strict";
      WorkingDirectory = "%h";
      Restart = "on-failure";
      RestartSec = "60s";
      Environment = "PATH=${pkgs.nix}/bin RUST_BACKTRACE=1";
    };
  };

  environment.systemPackages = [ lorri ];
}
