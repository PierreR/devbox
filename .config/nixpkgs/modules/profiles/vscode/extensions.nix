{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.vscode.extensions;
in

{
  options = {
    profiles.vscode.extensions = {
      enable = mkEnableOption "vscode-extensions";
    };
  };

  config = mkIf cfg.enable {
    programs.vscode.extensions = with pkgs.vscode-extensions; [
      bbenoist.Nix
      # ms-python.python
      justusadam.language-haskell
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "dhall-lang";
        publisher = "panaeon";
        version = "0.0.4";
        sha256 = "0qcxasjlhqvl5zyf7w9fjx696gnianx7c959g2wssnwyxh7d14ka";
      }
      {
        name = "org-mode";
        publisher = "vscode-org-mode";
        version = "1.0.0";
        sha256 = "1dp6mz1rb8awrrpig1j8y6nyln0186gkmrflfr8hahaqr668il53";
      }
      {
        name = "puppet-vscode";
        publisher = "jpogran";
        version = "0.20.0";
        sha256 = "07hd4ii3i2a9as8mdk0qv8mcfsk0p12zn9shzdkjf80i3nwimhv2";
      }
      # {
      # name = "vscode-dhall-lsp-server";
      # publisher = "panaeon";
      # version = "0.0.4";
      # sha256 = "0ws2ysra5iifhqd2zf7zy2kcymacr5ylcmi1i1zqljkpqqmvnv5q";
      # }
      {
        name = "Go";
        publisher = "ms-vscode";
        version = "0.6.89";
        sha256 = "05mzw4bwsa9wxldnkdgk0b4n4xm8gzhmrbqy6j8lbk3p360wdg8z";
      }
      {
        name = "asciidoctor-vscode";
        publisher = "joaompinto";
        version = "2.7.6";
        sha256 = "1mklszqcjn9sv6yv1kmbmswz5286mrbnhazs764f38l0kjnrx7qm";
      }
      # {
      # name = "shellcheck";
      # publisher = "timonwong";
      # version = "0.8.1";
      # sha256 = "0zg7ihwkxg0da0wvqcy9vqp6pyjignilsg9cldp5pp9s0in561cw";
      # }
    ];
  };
}
