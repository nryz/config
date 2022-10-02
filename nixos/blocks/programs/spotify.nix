{ config, lib, pkgs, ... }:

with lib;
with lib.my;
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
