# Local customization that won't be overridden by vagrant provision
{ config, lib, pkgs, ... }:

{
  environment.extraInit = ''
    export _JAVA_AWT_WM_NONREPARENTING=1 # Fix intelliJ blank popup
    export DESKTOP_SESSION=gnome
    export BROWSER=google-chrome-stable
  '';
  environment.systemPackages = with pkgs; [
    # atom
    bundix
    cabal2nix
    (eclipses.eclipseWithPlugins {
       eclipse = eclipses.eclipse-sdk-46;
       plugins = with eclipses.plugins; [ jdt yedit testng geppetto ];
     })
    # firefox
    # geany
    gitAndTools.tig
    gnome3.nautilus
    # go2nix
    google-chrome
    # gnome3.file-roller
    # jetbrains.idea-community
    # jetbrains.idea-ultimate
    # haskellPackages.xmobar
    jdk
    maven
    # nodePackages.tern
    # openssl
    # pandoc
    # parcellite
    # vscode
  ];

  # Uncomment these lines if you want to launch virtualbox from its UI
  #fileSystems."/vagrant" = {
  #  fsType = "vboxsf";
  #  device = "vagrant";
  #  options = [ "rw" ];
  #};

}
