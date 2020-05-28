{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.git;

in

{
  options = {
    profiles.git = {
      userName = mkOption {
        default = "";
        type = types.str;
      };
      userEmail = mkOption {
        default = "";
        type = types.str;
      };
    };
  };
  config = {
    programs.git = {
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      enable = true;
      aliases = {
        st = "status";
        co = "checkout";
        dt = "difftool";
        mt = "mergetool";
        df = "diff -w";
        ls = ''log --pretty=format:"%C(yellow)%h %C(blue)%ad%C(red)%d %C(reset)%s%C(green) [%cn]" --decorate --date=short'';
        ci = "commit -v";
      };
      extraConfig = {
        rebase.autostash = true;
        branch.autosetuprebase = "always";
        diff.compactionHeuristic = true;
      };
    };
  };
}
