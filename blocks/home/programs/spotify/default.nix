{ config, lib, pkgs, ... }:

let
  spotifyDesktop = pkgs.makeDesktopItem {
    name = "spotify";
    desktopName = "spotify";
    exec = "${pkgs.spotifywm}/bin/spotifywm";
  };
in
{
  home.packages = with pkgs; [
    spotifyDesktop
  ];
}
