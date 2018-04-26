# All the ui manager required for the ui configuration
# such as desktopManager, windowManager and displayManager
{ ... }:

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
        ${pkgs.feh}/bin/feh --bg-scale "$HOME/.wallpaper.jpg" &
        ${pkgs.taffybar}/bin/taffybar &
        # ${pkgs.dunst}/bin/dunst -cto 4 -nto 2 -lto 1 -config ${config.users.extraUsers.vagrant.home}/.dunstrc &
      '';
    };
  };
}
