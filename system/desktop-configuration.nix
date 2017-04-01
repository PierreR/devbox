# desktop ui configuration
{ ... }:

{
  services.xserver.desktopManager.default = "none";
  services.xserver.windowManager = {
    xmonad.enable = true;
    xmonad.enableContribAndExtras = true;
    default = "xmonad";
  };
}
