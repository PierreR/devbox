# All the ui manager required for the ui configuration
# such as desktopManager, windowManager and displayManager
{pkgs, config, ... }:

{
  services.xserver = {
    desktopManager = {
      gnome3.enable = true;
    };
    displayManager = {
      lightdm = {
        enable = true;
        autoLogin.user= "vagrant";
        autoLogin.enable= true;
      };
      sessionCommands = ''
        # ${pkgs.numlockx}/bin/numlockx on
        # ${pkgs.dunst}/bin/dunst -cto 4 -nto 2 -lto 1 -config ${config.users.extraUsers.vagrant.home}/.dunstrc &
      '';
    };
  };
}
