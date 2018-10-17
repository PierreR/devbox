# All the ui manager required for the ui configuration
# such as desktopManager, windowManager and displayManager
{pkgs, config, ... }:

let
  taffybar = import (fetchTarball {
    url = "https://github.com/pierrer/taffybar/tarball/20584dafc952fbe5ee36136e0492500749ea7faa";
    sha256 = "1l9llchl46ipvrn4vjcpyxsvmmdx98qx08w8frabfibf51vr6v2k";
  }) {};
in

{
  services.xserver = {
    desktopManager.default = "none";
    windowManager = {
      xmonad.enable = true;
      xmonad.extraPackages = hpkgs: [
        hpkgs.taffybar
        hpkgs.xmonad-contrib
        hpkgs.xmonad-extras
      ];
      default = "xmonad";
    };
    displayManager = {
      lightdm = {
        enable = true;
        autoLogin.user= "vagrant";
        autoLogin.enable= true;
      };
      sessionCommands = ''
        ${pkgs.xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr
        ${pkgs.numlockx}/bin/numlockx on
        ${taffybar}/bin/taffybar &
        ${pkgs.feh}/bin/feh --bg-scale "$HOME/.wallpaper.jpg" &
        # ${pkgs.dunst}/bin/dunst -cto 4 -nto 2 -lto 1 -config ${config.users.extraUsers.vagrant.home}/.dunstrc &
      '';
    };
  };
  environment.systemPackages = with pkgs; [
    albert
    feh
    stalonetray
    compton
  ];
}
