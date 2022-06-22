{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.mpv;
in
{
  options.blocks.programs.mpv = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      haruna
    ];

    programs.mpv = {
      enable = true;

      scripts = with pkgs.mpvScripts; [
        mpris
        mpv-playlistmanager
        sponsorblock
        #thumbnail
        youtube-quality
      ];
    };

    xdg.configFile."mpv/mpv.conf".text = ''
      keepaspect-window=no
      keepaspect=yes
      alang=Japanese,jpn,ja,English,eng,en
      slang=English,eng,en

    '';
  };
}
