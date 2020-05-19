{ config, lib, pkgs, ... }:

with lib;

let
  dhall = {
    version = "1.31.0";
    sha256 = "0x5dm1211k5wh2pxwzym2b2f70mv8nr5dvva5pykhsa90djb35dv";
  };
  dhall-nix = {
    version = "1.1.10";
    sha256 = "0cfpf74p9ydrszhmlqvjkjhgn1rx81q4257svpmn5xy6jlf35rdg";
  };
  lsp-server = {
    version = "1.0.5";
    sha256 = "00spk50y4ab9zza5rhjpgvv1xys4wmiaqry1m6bpscyh6r08bq0i";
  };
  cfg = config.programs.dhall;
in
{
  options.programs.dhall = {
    dhall = mkOption {
      default = null;
      type = with types; nullOr (submodule {
        options = {
          enable = mkEnableOption "dhall";
        };
      });
    };
    dhall-nix = mkOption {
      default = null;
      type = with types; nullOr ( submodule {
        options = {
          enable = mkEnableOption "dhall-nix";
        };
      });
    };
    lsp-server = mkOption {
      default = null;
      type = with types; nullOr ( submodule {
        options = {
          enable = mkEnableOption "lsp-server";
        };
      });
    };
  };
  config =
    let
      dhallPath = fetchTarball {
        url = "https://github.com/dhall-lang/dhall-haskell/releases/download/${dhall.version}/dhall-${dhall.version}-x86_64-linux.tar.bz2";
        inherit (dhall) sha256;
      };
      dhallNixPath = fetchTarball {
        url = "https://github.com/dhall-lang/dhall-haskell/releases/download/${dhall.version}/dhall-nix-${dhall-nix.version}-x86_64-linux.tar.bz2";
        inherit (dhall-nix) sha256;
      };
      lspServerPath = fetchTarball {
        url = "https://github.com/dhall-lang/dhall-haskell/releases/download/${dhall.version}/dhall-lsp-server-${lsp-server.version}-x86_64-linux.tar.bz2";
        inherit (lsp-server) sha256;
      };
    in
      mkMerge [
        (
          mkIf (! isNull cfg.dhall && cfg.dhall.enable) {
            home.file.".local/bin/dhall".source = "${dhallPath}/bin/dhall";
          }
        )
        (
          mkIf (! isNull cfg.dhall-nix && cfg.dhall-nix.enable) {
            home.file.".local/bin/dhall-to-nix".source = "${dhallNixPath}/bin/dhall-to-nix";
          }
        )
        (
          mkIf (! isNull cfg.lsp-server && cfg.lsp-server.enable) {
            home.file.".local/bin/dhall-lsp-server".source = "${lspServerPath}/bin/dhall-lsp-server";
          }
        )
      ];
}
