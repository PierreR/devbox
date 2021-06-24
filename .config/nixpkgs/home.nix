{ config, pkgs, lib, ... }:
let
  sharedDir = builtins.getEnv "SHARED_DIR";
  configData = import ./box.nix { inherit config pkgs sharedDir; };
  defaultStacks = lib.concatMapStringsSep "," (x: "\"" + x + "\"") configData.defaultStacks;
  puppet-vim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "puppet-vim";
    src = pkgs.fetchgit {
      url = "https://github.com/rodjek/vim-puppet.git";
      rev = "fc6e9efef797c505b2e67631ad2517d7d6e8f00d";
      sha256 = "0a4qv8f74g6c2i9l6kv3zbcq9lskhdqg86w12f8hshw1vkfmfr4x";
    };
  };
in
{
  imports = [
    ./modules/profiles
    ./modules/services
    ./modules/programs
    "${sharedDir}/local-home.nix"
  ];


  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.sessionVariables = {
    LOGINID = "${configData.loginId}";
    DIRENV_WARN_TIMEOUT = "60s";
  };

  home.packages = with pkgs; [
    ansible
    fd
    openssl
    ripgrep
    vault
  ];

  home.keyboard.layout = "be";

  home.file = {

    ".config/generated/config.nix".text = "${configData}";

    ".config/cicd/shell.dhall".text = ''
      { loginId = env:LOGINID as Text, defaultStacks = [${defaultStacks}] }
    '';

  };
  programs.autojump.enable = true;

  programs.vscode = {
    inherit (configData.vscode) enable;
    userSettings = {
      editor.cursorBlinking = "visible";
      files.autoSave = "onFocusChange";
      update.channel = "none";
      git.autofetch = true;
      telemetry.enableTelemetry = false;
      puppet.editorService.enable = false;
      shellcheck.customArgs = [ "-x" ];
      files.trimTrailingWhitespace = true;
      nix.editor.tabSize = 2;
      diffEditor.renderSideBySide = true;
      editor.minimap.enabled = configData.vscode.minimap or true;
    };
  };

  profiles.xmonad = {
    inherit (configData.defaultUI) enable wallpaper netw appLauncherHotkey;
  };

  profiles.git = {
    userName = configData.userName;
    userEmail = configData.userEmail;
  };

  profiles.zsh = {
    enable = true;
    theme = configData.zsh.theme or "simple";
    enableCompletion = configData.zsh.enableCompletion or true;
    enableAutosuggestions = configData.zsh.enableAutosuggestions or false;
  };

  profiles.bash.enable = true;

  profiles.mr = {
    enable = configData.mr.enable or true;
    configExtra = configData.mr.config;
    repos = configData.mr.repos;
  };

  profiles.gpg.enable = true;
  profiles.ocp.enable = configData.ocp or false;
  profiles.eclipse.enable = configData.eclipse or false;
  profiles.vscode.extensions.enable = configData.vscode.manageExtension or false;

  profiles.doc = {
    enable = configData.doc or true;
    srcPath = /. + config.home.homeDirectory + /bootstrap/docs;
  };

  profiles.direnv.enable = configData.direnv or true;

  programs.alacritty = {
    enable = true;
    settings =
    {
      font.normal = {
        family = "Source Code Pro";
        style = "Medium";
      };
      font.size = 10.0;
      colors.primary = {
        background = configData.console.background or "#2e3440";
        foreground = configData.console.foreground or "#d8dee9";
      };
      cursor.style = configData.alacritty.cursor.style or "Beam";
      key_bindings = [
        { key = "Equals"; mods =  "Control"; action = "ResetFontSize";}
        { key = "Plus"; mods = "Control|Shift"; action = "IncreaseFontSize";}
      ];
    };
  };

  programs.cicd.enable = configData.cicd-shell or true;

  programs.neovim = {
    vimAlias = true;
    enable = true;
    extraConfig = ''
      if has('unnamedplus')
        set clipboard=unnamed,unnamedplus
      endif
      set directory=~/tmp
      set gdefault
      set hidden
      set smartcase
      set history=50
      set nobackup
      set noswapfile
      set wildignore+=*.pyc,*.jar,*.pdf,*.class,/tmp/*.*,.git,*.o,*.obj,*.png,*.jpeg,*.gif,*.orig,target/*,*.6,*.a,*.out,*.hi
      set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
      set t_Co=256
      set undofile
      set undodir=/tmp
      set cursorline
      set nu
      colorscheme slate
      hi CursorLine cterm=${configData.console.cterm or "NONE"} ctermbg=${configData.console.ctermbg or "254"}
    '';
    plugins = with pkgs.vimPlugins; [ surround sensible vim-nix ctrlp puppet-vim editorconfig-vim dhall-vim vim-fugitive bufexplorer vim-nix vim-terraform direnv-vim ];
  };


  services.lorri.enable = configData.lorri or false;
}
