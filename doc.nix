{ pkgs ? import <nixpkgs> { config = {}; overlays = []; } } :

let
  src = ./docs;
in
pkgs.runCommand "doc"
  {
    preferLocalBuild = true;
    buildInputs = [ pkgs.asciidoctor ];
  }
  ''
    mkdir $out
    cp ${src}/modules/ROOT/assets/images/*.* $out
    asciidoctor ${src}/modules/ROOT/pages/index.adoc -a docinfodir=${src} -o $out/devbox.html
  ''