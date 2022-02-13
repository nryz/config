{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.sites.youtube;
in
{
  options.blocks.sites.youtube = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.directories = [
      ".cache/sponsorblock_shared"
      ".cache/ytfzf"
    ];

    home.packages = with pkgs; [
      (pkgs.writers.writePython3Bin "yt-subs-to-opml" {} (builtins.readFile ./youtube-subs-to-opml.py))
      pipe-viewer
      #freetube
      #gtk-pipe-viewer
      youtube-dl
      yt-dlp
      ytfzf
      ytcc
      timg
    ];
  };
}
