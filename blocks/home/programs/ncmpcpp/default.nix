{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.ncmpcpp;

  ncmpcppDesktop = pkgs.makeDesktopItem {
    name = "ncmpcpp";
    desktopName = "ncmpcpp";
    exec = "ncmpcpp";
    terminal = true;
  };
in
{
  options.blocks.programs.ncmpcpp = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.directories = [ ".local/share/mpd" ];
    services.mpd = {
      enable = true;
    };

    programs.ncmpcpp = {
      enable = true;
    };

    home.packages = [ ncmpcppDesktop ];
  };
}
