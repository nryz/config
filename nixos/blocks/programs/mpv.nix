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
    hm.programs.mpv = {
      enable = true;

      scripts = with pkgs.mpvScripts; [
        mpris
        mpv-playlistmanager
        #sponsorblock
        #thumbnail
        youtube-quality
      ];
    };

    hm.xdg.configFile."mpv/mpv.conf".text = ''
      keepaspect-window=no
      keepaspect=yes
      alang=Japanese,jpn,ja,English,eng,en
      slang=English,eng,en
      script-opts=ytdl_hook-ytdl_path=${pkgs.yt-dlp}/bin/yt-dlp
    '';
  };
}
