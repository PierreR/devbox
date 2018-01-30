# Local customization that won't be overridden by vagrant provision
{ config, lib, pkgs, ... }:

{
  environment.extraInit = ''
    export _JAVA_AWT_WM_NONREPARENTING=1 # Fix intelliJ blank popup
    export DESKTOP_SESSION=gnome
    export BROWSER=google-chrome-stable
  '';
  environment.systemPackages = with pkgs; [
    # ansible
    # atom
    bind
    # bundix
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
    # nix-repl
    # nodejs
    # nodePackages.tern
    # openssl
    # pandoc
    # parcellite
    python
    # ruby
    # rxvt_unicode-with-plugins
    # sublime3
    # tmux
    # vscode
  ];

  # Uncomment the paragraph below if you want to launch virtualbox from its UI
  #fileSystems."/vagrant" = {
  #  fsType = "vboxsf";
  #  device = "vagrant";
  #  options = [ "rw" ];
  #};

  # Uncomment the paragraph below if you want to set up a postgresql server
  # services.postgresql = {
  #   enable = true;
  # #  authentication = ''
  # #    local saltstack salt trust
  # #  '';
  # #   initialScript = /vagrant/initdb.sql;
  # };

  # Uncomment the paragraph below if you want to play with salt locally
  # networking.extraHosts = ''
  #   127.0.0.1 salt
  # '';
  # services.salt.master = {
  #   enable = true;
  # };
  # services.salt.minion.enable = true;
}
