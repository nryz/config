{ config, lib, libs, pkgs, ... }:

with lib;
with libs.flake;
let
  cfg = config.blocks.programs.spotify;

  spotifyDesktop = pkgs.makeDesktopItem {
    name = "spotify";
    desktopName = "spotify";
    exec = "${pkgs.spotifywm}/bin/spotifywm";
  };
in
{
  options.blocks.programs.spotify = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.userDirectories = [ ".config/spotify" ];

    hm.home.packages = with pkgs; [
      spotifyDesktop
    ];
  };
}
