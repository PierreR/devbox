{ config, pkgs, lib, ... }:

let
  sharedDir = builtins.getEnv "SHARED_DIR";
  configData = pkgs.dhallToNix (builtins.readFile "${sharedDir}/box.dhall");
  defaultStacks = lib.concatMapStringsSep "," (x: "\"" + x + "\"") configData.defaultStacks;
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

  home.file.".nix-channels".text = ''
    https://releases.nixos.org/nixos/20.03/nixos-20.03.1917.82b5f87fcc7/nixexprs.tar.xz nixpkgs
    https://github.com/rycee/home-manager/archive/release-20.03.tar.gz home-manager
  '';
  home.packages = with pkgs; [
    ansible
    facter
    git-crypt
    gnupg
    nixpkgs-fmt
    shellcheck
  ];

  programs.cicd.enable = configData.cicd-shell or true;

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
    };
  };

  programs.direnv.enable = configData.direnv or true;

  home.keyboard.layout = "be";

  home.file = {

    ".config/termite/config".source = ../termite + ("/" + configData.console.color);

    ".config/cicd/shell.dhall".text = ''
      { loginId = env:LOGINID as Text, defaultStacks = [${defaultStacks}] }
    '';

  };

  profiles.xmonad = {
    inherit (configData.defaultUI) enable wallpaper netw appLauncherHotkey;
  };

  profiles.git = {
    userName = configData.userName;
    userEmail = configData.userEmail;
  };

  profiles.zsh = {
    inherit sharedDir;
    loginId = configData.loginId;
  };

  profiles.mr = {
    enable = configData.mr.enable or true;
    configExtra = configData.mr.config;
    repos = configData.mr.repos;
  };

  profiles.vscode.extensions.enable = configData.vscode.manageExtension or false;
  profiles.ocp.enable = configData.ocp or false;
  profiles.eclipse.enable = configData.eclipse or false;

  profiles.doc = {
    enable = configData.doc or true;
    srcPath = /. + config.home.homeDirectory + /bootstrap/docs;
  };

  services.lorri.enable = configData.lorri or false;

}
