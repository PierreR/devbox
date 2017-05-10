# desktop ui configuration
{ ... }:

{
  services.xserver.desktopManager.default = "none";
  services.xserver.videoDriver = "virtualbox";
  services.xserver.windowManager = {
    xmonad.enable = true;
    xmonad.extraPackages = hpkgs: [
      hpkgs.taffybar
      hpkgs.xmonad-contrib
      hpkgs.xmonad-extras
    ];
    default = "xmonad";
  };
}
