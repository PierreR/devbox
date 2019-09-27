# Place here any custom configuration specific to your organisation (locale, terminal, ...)
# if you want it to be part of the packer base image to be used with vagrant.
{ config, pkgs, ... }:

{

  boot.loader.timeout = 1;
  boot.plymouth.enable = true;

  networking.enableIPv6 = false;

  security.pki.certificateFiles = [ ./CIRB_CIBG_ROOT_PKI.crt ];

  nix = {
    extraOptions = ''
      gc-keep-outputs = true
      gc-keep-derivations = true
    '';
    gc.automatic = true;
    trustedUsers = [ "root" "vagrant"];
    binaryCaches = [
      "https://cache.nixos.org/"
      "https://cache.dhall-lang.org"
      "https://cicd-shell.cachix.org"
      "https://language-puppet.cachix.org"
      "https://repository.irisnet.be/artifactory/nix/"
      "https://puppet-unit-test.cachix.org"
    ];
    binaryCachePublicKeys = [
      "cache.dhall-lang.org:I9/H18WHd60olG5GsIjolp7CtepSgJmM2CsO813VTmM="
      "cicd-shell.cachix.org-1:ajBUZoJNroJ5ldybYoXgXyl2YWuPJ4NJ8Qx3/ksxVEw="
      "language-puppet.cachix.org-1:nyTkkiphUF+s5HO4aDqGXBHD7rGiqz6ygvGYnJQ2feA="
      "puppet-unit-test.cachix.org-1:DcfU2u/QnYWzfTFpjIPEQi1/Nq//yd1lhgORL5+Uf84="
    ];
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "be-latin1";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Amsterdam";
  security.sudo.wheelNeedsPassword = false;

  services.xserver = {
    enable = true;
    layout = "be";
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
    direnv
    docker
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
    openshift
    paper-gtk-theme
    paper-icon-theme
    psmisc
    silver-searcher
    shared_mime_info
    termite
    tree
    unzip
    vcsh
    wget
    which
    zip
  ];

  users.users.vagrant.shell = pkgs.zsh;
  users.users.vagrant.extraGroups = [ "docker" ];
  
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
    if config.virtualisation.virtualbox.guest.enable then
      {
        fsType = "vboxsf";
        device = "vagrant";
        options = [ "rw" ];
      }
    else if config.virtualisation.vmware.guest.enable then
      {
        fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
        device = ".host:/";
        options = [ "allow_other" "uid=1000" "gid=100" "auto_unmount" "defaults"];
      }
    else
      throw "Unsupported builder";

  nixpkgs.config.allowUnfree = true;

}
