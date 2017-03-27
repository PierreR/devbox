# window manager configuration
{ ... }:

{
  services.xserver.windowManager = {
    xmonad.enable = true;
    xmonad.enableContribAndExtras = true;
    default = "xmonad";
  };
}
