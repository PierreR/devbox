{ config, pkgs, sharedDir }:
let
  cueSchema = "${config.home.homeDirectory}/bootstrap/user/schema.cue";
  cueConfig = "${sharedDir}/box.cue";
  fromDhall = pkgs.lib.strings.fileContents "${sharedDir}/box.dhall";
  fromCUE = pkgs.lib.strings.fileContents
    (
      pkgs.runCommand "fromCUE" { } ''
        ${pkgs.cue}/bin/cue export ${/. + cueSchema } ${/. + cueConfig} > $out;
      ''
    );
in
if builtins.pathExists cueConfig
then builtins.fromJSON fromCUE // { outPath = fromCUE; }
else pkgs.dhallToNix fromDhall // { outPath = fromDhall; }
