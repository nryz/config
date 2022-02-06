{ config, lib, pkgs, ... }:

{
  programs.mpv = {
    enable = true;

    scripts = with pkgs.mpvScripts; [
      autoload
      mpris
      mpv-playlistmanager
      sponsorblock
      thumbnail
      youtube-quality
    ];

    config = {
      osc = "no";
      "keepaspect-window" = "no";
      "keepaspect" = "yes";
    };
  };
}
