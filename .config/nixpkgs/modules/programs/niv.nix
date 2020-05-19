{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.niv;
  sources = import ../../nix/sources.nix;
  nivRecordSet = import sources.niv {};
in

{
  options.programs.niv = {
    enable = mkEnableOption "Niv";
  };
  config = mkIf cfg.enable {
    home.packages = [ nivRecordSet.niv ];
  };
}
