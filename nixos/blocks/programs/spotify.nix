{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
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
    my.state.user.directories = [ ".config/spotify" ];

    hm.home.packages = with pkgs; [
      spotifyDesktop
    ];
  };
}
