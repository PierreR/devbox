{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.doc;
  homeDir = config.home.homeDirectory;
in
{
  options = {
    profiles.doc = {
      enable = mkEnableOption "doc";
      srcPath = mkOption {
        type = types.path;
      };
    };
  };
  config = mkIf (cfg.enable && builtins.pathExists cfg.srcPath) {
    home.file.".local/share/devbox".source =
      let
        indexFile = "${cfg.srcPath}/modules/tools/pages/devbox/index.adoc";
      in
        pkgs.runCommand "doc"
          {
            preferLocalBuild = true;
            allowSubstitutes = false;
            buildInputs = [ pkgs.asciidoctor ];
          }
          ''
            mkdir $out
            cp -r ${cfg.srcPath}/modules/tools/assets/images $out
            asciidoctor ${indexFile} -a docinfodir=${cfg.srcPath} -a imagesdir=$out/images -o $out/devbox.html
            asciidoctor ${indexFile} -r asciidoctor-pdf -b pdf -a imagesdir=${cfg.srcPath}/modules/tools/assets/images -o $out/devbox.pdf
          '';
  };
}
