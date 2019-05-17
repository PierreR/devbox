# Place here any custom configuration specific to your organisation (locale, terminal, ...)
# if you want it to be part of the packer base image to be used with vagrant.
{ config, pkgs, ... }:

{
  imports = [
    ./local-configuration.nix
  ];

  boot.loader.timeout = 1;
  boot.plymouth.enable = true;

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
  };

  time.timeZone = "Europe/Amsterdam";
  security.sudo.wheelNeedsPassword = false;

  services.xserver = {
    enable = true;
    layout = "be";
    xkbOptions = "caps:escape";
  };

  environment.pathsToLink = [ "/share" ];
  environment.systemPackages = with pkgs; [
    autojump
    aspell
    aspellDicts.en
    aspellDicts.fr
    bind
    binutils
    curl
    desktop_file_utils
    gitFull
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
    psmisc
    shared_mime_info
    termite
    tree
    vcsh
    wget
    which
    zsh
    zsh-completions
  ];

  # zsh config
  programs.zsh = {
    enable = true;
    ohMyZsh.enable = true;
    ohMyZsh.custom = "$HOME/.zsh_custom";
    ohMyZsh.theme = "lambda-mod";
    ohMyZsh.plugins = [ "cicd" "autosuggestion"];
    interactiveShellInit = ''
      setopt globdots
      nlink () {
          readlink -f $(which "$1")
      }
    '';
    shellAliases = {
      la = " ls -alh";
      ls = " ls --color=tty";
      ll = "ls -lh";
      duh = " du -h --max-depth=1";
      df = " df -h";
      ag = "ag --color-line-number=3";
      vi = "vim";
      chrome = "google-chrome-stable";
      see = "./bin/check_role.sh";
      heyaml = "./bin/eyaml.sh $@";
      fixlint = "./bin/fix-lint.sh";
      nixreb = "sudo nixos-rebuild switch";
      ldir = "ls -ladh (.*|*)(/,@)";
      lfile = "ls -lah *(.)";
    };
  };

  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

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

  nixpkgs.config.allowUnfree = true;

  users.users.vagrant.extraGroups = [ "docker" ];
}
