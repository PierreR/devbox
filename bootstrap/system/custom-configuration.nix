# Place here any custom configuration specific to your organisation (locale, terminal, ...)
# if you want it to be part of the packer base image to be used with vagrant.
{ config, pkgs, ... }:

let isVmware = config.virtualisation.vmware.guest.enable;
    isVirtualbox = config.virtualisation.virtualbox.guest.enable;
in
{
  imports = [
    ./local-configuration.nix
  ];

  boot.loader.timeout = 1;
  boot.plymouth.enable = true;

  networking.enableIPv6 = false;
  networking.nameservers = [ "192.168.34.244" "172.28.131.10"];

  security.pki.certificateFiles = [ ./CIRB_CIBG_ROOT_PKI.crt ./CIRB_CIBG_SERVER_CA.crt ];

  nix = {
    extraOptions = ''
      gc-keep-outputs = true
      gc-keep-derivations = true
    '';
    gc.automatic = true;
    trustedUsers = [ "root" "vagrant"];
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
      lightdm = {
        enable = true;
        autoLogin.user= "vagrant";
        autoLogin.enable= true;
      };
    };
  };

  environment.extraInit = ''
    export _JAVA_AWT_WM_NONREPARENTING=1 # Fix intelliJ blank popup
    export DESKTOP_SESSION=gnome
    export BROWSER=google-chrome-stable
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
    ( neovim.override {
        vimAlias = true;
        configure = {
          vam.knownPlugins = vimPlugins // ({
            puppet-vim = vimUtils.buildVimPluginFrom2Nix {
              name = "puppet-vim";
              src = fetchgit {
                url = "https://github.com/rodjek/vim-puppet.git";
                rev = "bffbd2955ef8025cbc3d8af0f3c929c07e4bd45f";
                sha256 = "1kh7asvm4m9m25wqq370qmqxnq27cbqbcgd2r5zyadlnj5ymzp42";
              };
              dependencies = [];
            };
          });
          customRC = ''
            if has('unnamedplus')
              set clipboard=unnamed,unnamedplus
            endif
            set cpoptions+=$
            set cursorline
            set directory=~/tmp
            set enc=utf-8
            set gdefault
            set hidden
            set history=50
            set hlsearch
            set nobackup
            set noswapfile
            set smartcase
            set showcmd
            set t_Co=256
            set undofile
            set undodir=/tmp
            set wildignore+=*.pyc,*.jar,*.pdf,*.class,/tmp/*.*,.git,*.o,*.obj,*.png,*.jpeg,*.gif,*.orig,target/*,*.6,*.a,*.out,*.hi
            set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
            colorscheme slate
            hi CursorLine cterm=NONE ctermbg=254
          '';
          vam.pluginDictionaries = [
            { names = [
              "ctrlp"
              "puppet-vim"
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

  users.users.vagrant.shell = pkgs.zsh;
  users.users.vagrant.extraGroups = [ "docker" ];
  users.users.vagrant.subGidRanges = [ { startGid = 1001; count = 65535; } ];
  users.users.vagrant.subUidRanges = [ { startUid = 1001; count = 65535; } ];

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
        serif     = [ "Source Serif Pro" ];
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
        options = [ "allow_other" "uid=1000" "gid=100" "auto_unmount" "defaults"];
      }
    else
      throw "Unsupported builder";

  environment.sessionVariables = {
    SHARED_DIR = if isVmware then "/vagrant/shared" else "/vagrant";
  };

  environment.etc."containers/registries.conf".text = ''
    [registries.search]
    registries = ['docker.io', 'quay.io', 'registry.access.redhat.com']
  '';
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
