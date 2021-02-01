# Place here any custom configuration specific to your organisation (locale, terminal, ...)
# if you want it to be part of the packer base image to be used with vagrant.
{ config, pkgs, ... }:
let
  isVmware = config.virtualisation.vmware.guest.enable;
  isVirtualbox = config.virtualisation.virtualbox.guest.enable;
in
{
  imports = [
    ./local-configuration.nix
  ];

  boot.loader.timeout = 1;
  boot.plymouth.enable = true;

  networking.enableIPv6 = false;
  networking.nameservers = [ "192.168.34.244" "172.28.131.10" ];
  networking.hosts = {
    "192.168.135.33" = [ "stash.cirb.lan" ];
  };

  security.pki.certificateFiles = [ ./CIRB_CIBG_ROOT_PKI.crt ./CIRB_CIBG_SERVER_CA.crt ./CIRB_CIBG_SUBCA_PRD.crt ./CIRB_CIBG_SERVICE_FW_CA.crt ];

  nix = {
    extraOptions = ''
      gc-keep-outputs = true
      gc-keep-derivations = true
    '';
    gc.automatic = true;
    trustedUsers = [ "root" "vagrant" ];
    binaryCachePublicKeys = [
      "cache.dhall-lang.org:I9/H18WHd60olG5GsIjolp7CtepSgJmM2CsO813VTmM="
    ];
  };

  console.font = "Lat2-Terminus16";
  console.keyMap = "be-latin1";
  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Amsterdam";
  security.sudo.wheelNeedsPassword = false;

  services.xserver = {
    enable = true;
    layout = "be";
    xkbOptions = "caps:escape";
    desktopManager.session = [
      {
        name = "home-manager";
        start = ''
          ${pkgs.runtimeShell} $HOME/.hm-xsession &
          waitPID=$!
        '';
      }
    ];
    displayManager = {
      autoLogin.user = "vagrant";
      autoLogin.enable = true;
      lightdm = {
        enable = true;
      };
    };
  };

  environment.extraInit = ''
    export _JAVA_AWT_WM_NONREPARENTING=1 # Fix intelliJ blank popup
    export DESKTOP_SESSION=gnome
    export BROWSER=google-chrome-stable
    export EDITOR='vim'
    export NIX_PATH=$NIX_PATH:nixpkgs-overlays=http://stash.cirb.lan/CICD/nixpkgs-overlays/archive/20.09.tar.gz
  '';

  environment.pathsToLink = [ "/share" ];
  environment.systemPackages = with pkgs; [
    autojump
    aspell
    aspellDicts.en
    aspellDicts.fr
    binutils
    bind
    curl
    desktop_file_utils
    gitFull
    google-chrome
    htop
    (neovim.override {
      vimAlias = true;
      configure = {
        customRC = ''
          if has('unnamedplus')
            set clipboard=unnamed,unnamedplus
          endif
          set gdefault
          set hlsearch
          set smartcase
          set showcmd
          set t_Co=256
          set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
          set undofile
          set undodir=/tmp
        '';
        vam.pluginDictionaries = [
          {
            names = [
              "sensible"
              "surround"
              "vim-nix"
            ];
          }
        ];
      };
    })
    mr
    paper-gtk-theme
    paper-icon-theme
    psmisc
    silver-searcher
    shared_mime_info
    termite
    tree
    unzip
    vcsh
    vscode
    wget
    which
    zip
  ];

  users.users.vagrant.extraGroups = [ "docker" ];
  users.users.vagrant.subGidRanges = [{ startGid = 1001; count = 65535; }];
  users.users.vagrant.subUidRanges = [{ startUid = 1001; count = 65535; }];

  virtualisation.docker.enable = true;

  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = [
      pkgs.source-code-pro
      pkgs.source-sans-pro
      pkgs.source-serif-pro
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "Source Code Pro" ];
        sansSerif = [ "Source Sans Pro" ];
        serif = [ "Source Serif Pro" ];
      };
    };
  };

  # Setup shared directory
  fileSystems."/vagrant" =
    if isVirtualbox then
      {
        fsType = "vboxsf";
        device = "vagrant";
        options = [ "rw" ];
      }
    else if isVmware then
      {
        fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
        device = ".host:/";
        options = [ "allow_other" "uid=1000" "gid=100" "auto_unmount" "defaults" ];
      }
    else
      throw "Unsupported builder";

  environment.sessionVariables = {
    SHARED_DIR = if isVmware then "/vagrant/shared" else "/vagrant";
  };

  environment.etc."containers/policy.json".text = ''
    {
      "default": [
          {
              "type": "insecureAcceptAnything"
          }
      ]
    }
  '';

  nixpkgs.config.allowUnfree = true;

}
