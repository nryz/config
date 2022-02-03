{ config, lib, pkgs, ... }:

let
  ncmpcppDesktop = pkgs.makeDesktopItem {
    name = "ncmpcpp";
    desktopName = "ncmpcpp";
    exec = "ncmpcpp";
    terminal = true;
  };
in
{
  persist.directories = [ ".local/share/mpd" ];
  services.mpd = {
    enable = true;
  };

  programs.ncmpcpp = {
    enable = true;
  };

  home.packages = [ ncmpcppDesktop ];
}
