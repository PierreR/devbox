# All the ui manager required for the ui configuration
# such as desktopManager, windowManager and displayManager
{pkgs, config, ... }:

{
  services.xserver = {
    enable = true;
    desktopManager = {
      plasma5.enable = true;
    };
    displayManager = {
      lightdm = {
        enable = true;
        autoLogin.user= "vagrant";
        autoLogin.enable= true;
      };
    };
  };
}
