{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./local-configuration.nix
    ];

  boot.loader.timeout = 1;
  # Use GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.plymouth.enable = true;

  # remove the fsck that runs at startup. It will always fail to run, stopping
  # your boot until you press *.
  boot.initrd.checkJournalingFS = false;

  networking.enableIPv6 = false;

  nix = {
    extraOptions = ''
      gc-keep-outputs = true
      gc-keep-derivations = true
    '';
    gc.automatic = true;
    trustedUsers = [ "root" "vagrant"];
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "be-latin1";
    defaultLocale = "en_US.UTF-8";
  } ;

  time.timeZone = "Europe/Amsterdam";

  services.dbus.enable = true;
  services.gnome3.at-spi2-core.enable = true;
  services.ntp.enable = false;
  services.openssh.enable = true;
  services.openssh.allowSFTP = false;
  services.openssh.passwordAuthentication = false;

  services.unclutter-xfixes = {
    enable = true;
  };

  services.xserver = {
    videoDriver = "virtualbox";
    enable = true;
    layout = "be";
    xkbOptions = "caps:escape";
  };
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


  environment.pathsToLink = [ "/share" ];

  environment.systemPackages = with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.fr
    autojump
    curl
    desktop_file_utils
    docker
    findutils
    gitFull
    gnome3.dconf
    gnupg
    gnumake
    gvfs # needed by xdg-mime (albert)
    htop
    iotop
    iputils
    jq
    libnotify
    mr
    nettools
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
    netcat
    nfs-utils
    numix-gtk-theme
    numix-icon-theme
    rsync
    oh-my-zsh
    paper-gtk-theme
    paper-icon-theme
    psmisc
    shared_mime_info
    silver-searcher
    termite
    tree
    unzip
    vcsh
    wget
    which
    xdg_utils
    xsel
    zip
    zsh
    zsh-completions
  ];

  # Creates a "vagrant" users with password-less sudo access
  users = {
    extraGroups = [ { name = "vagrant"; } { name = "vboxsf"; } ];
    extraUsers  = [
      # Try to avoid ask password
      { name = "root"; password = "vagrant"; }
      {
        description     = "Vagrant User";
        name            = "vagrant";
        group           = "vagrant";
        extraGroups     = [ "users" "vboxsf" "wheel" "docker" ];
        password        = "vagrant";
        home            = "/home/vagrant";
        createHome      = true;
        useDefaultShell = true;
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
        ];
      }
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  security.sudo.configFile =
    ''
      Defaults:root,%wheel env_keep+=LOCALE_ARCHIVE
      Defaults:root,%wheel env_keep+=NIX_PATH
      Defaults:root,%wheel env_keep+=TERMINFO_DIRS
      Defaults env_keep+=SSH_AUTH_SOCK
      Defaults lecture = never
      root   ALL=(ALL) SETENV: ALL
      %wheel ALL=(ALL) NOPASSWD: ALL, SETENV: ALL
    '';

  programs.bash.enableCompletion = true;

  programs.bash.shellAliases = {
    la = " ls -alh";
    ls = " ls --color=tty";
    du = " du -h";
    df = " df -h";
    ag = "ag --color-line-number=2";
    build = "./build/build.sh";
    see = "./bin/check_role.sh";
    fixlint = "./bin/fix-lint.sh";
    chrome = "google-chrome-stable";
  };

  programs.bash.interactiveShellInit = ''
    shopt -s autocd
    shopt -s histappend

    export HISTCONTROL=ignoreboth

  '';

  programs.zsh.enable = true;
  programs.zsh.interactiveShellInit = ''
    setopt globdots
    export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/

    nlink () {
        readlink -f $(which "$1")
    }

  '';
  programs.zsh.shellAliases = {
    la = " ls -alh";
    ls = " ls --color=tty";
    ll = "ls -lh";
    duh = " du -h --max-depth=1";
    df = " df -h";
    ag = "ag --color-line-number=3";
    vi = "vim";
    chrome = "google-chrome-stable";
    build = "./build/build.sh";
    see = "./bin/check_role.sh";
    heyaml = "./bin/eyaml.sh $@";
    fixlint = "./bin/fix-lint.sh";
    nixreb = "sudo nixos-rebuild switch";
    ldir = "ls -ladh (.*|*)(/,@)";
    lfile = "ls -lah *(.)";
  };
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  system.stateVersion = "18.03";

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = super:
      let self = super.pkgs;
          salt = super.salt.override {
            extraInputs = [super.python2Packages.psycopg2];
          };
      in { inherit salt; };
  };

  systemd.tmpfiles.rules = [ "d /tmp 1777 root root 10d" ];
}
