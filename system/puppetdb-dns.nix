#
{pkgs, config, lib, ... }:

with lib;

let
  cfg = config.services.puppetdb-dns;
  puppetdb-dns = pkgs.buildGoPackage rec {
    name = "puppetdb-dns-${version}";
    version = "20161124-${pkgs.stdenv.lib.strings.substring 0 7 rev}";
    rev = "1ff4b5fe9f45c66da0fba4ab3ec0f833a241dd57";
    goPackagePath = "github.com/jfroche/puppetdb-dns";
    src = pkgs.fetchgit {
      inherit rev;
      url = "https://github.com/jfroche/puppetdb-dns";
      sha256 = "11ba2f1985z7z2iwycvjkpky957v7b5s9n124yd26dqbfksx1rjs";
    };
    goDeps = /etc/cicd/puppetdb-dns/deps.nix;
  };

in

{

  options.services.puppetdb-dns = {
    enable = mkOption {
      description = "Whether to enable the puppetdb-dns service";
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.puppetdb-dns = {
      description = "Puppetdb DNS service";
      after = [ "network.target" "systemd-dnsmasq.service" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${puppetdb-dns}/bin/puppetdb-dns -conf /etc/cicd/puppetdb-dns/dns.conf
      '';
    };
    services.dnsmasq.enable = true;
    services.dnsmasq.extraConfig = ''
      server = /cicd/127.0.0.1#5354
    '';
  };
}
