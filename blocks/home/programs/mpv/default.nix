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
  };
}
