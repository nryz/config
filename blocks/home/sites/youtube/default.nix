{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pkgs.writers.writePython3Bin "yt-subs-to-opml" {} (builtins.readFile ./youtube-subs-to-opml.py))
    pipe-viewer
    #freetube
    #gtk-pipe-viewer
    youtube-dl
    yt-dlp
    ytfzf
    ytcc
  ];
}
