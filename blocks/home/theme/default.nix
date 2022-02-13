{ config, lib, pkgs, flakePath, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.theme;
in
{
  options.blocks.theme = with types; {
    enable = mkOpt bool false;

    background = mkOpt' str;

    colour = mkOpt' str;

    wm.gap = mkOpt' int;
    wm.border = mkOpt' int;
    wm.bar.size = mkOpt' int;
    wm.bar.enable = mkOpt' bool;

    font = mkOpt' (nullOr hm.types.fontType);

    gtk.theme = {
      package = mkOpt' (nullOr package);
      name = mkOpt' str;
    };

    gtk.iconTheme = {
      package = mkOpt' (nullOr package);
      name = mkOpt' str;
    };
  };

  config = mkIf cfg.enable {
    gtk = {
      enable = true;

      theme = config.blocks.theme.gtk.theme;
      iconTheme = config.blocks.theme.gtk.iconTheme;
      font = config.blocks.theme.font;

      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    };
  };
}
