{ config, lib, pkgs, flakePath, ... }:

with lib;
with lib.my;
{
  options.theme = with types; {
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

  config = {
    gtk = {
      enable = true;

      theme = config.theme.gtk.theme;
      iconTheme = config.theme.gtk.iconTheme;
      font = config.theme.font;
    };


    home.file."${config.home.homeDirectory}/Pictures/backgrounds" = {
      recursive = true;
      source = flakePath + /data/backgrounds;
    };

    systemd.user.services.background = {
      Unit = {
        Description = "set background";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.feh}/bin/feh --bg-fill --no-fehbg ${config.home.homeDirectory}/Pictures/backgrounds/${config.theme.background}";
        IOSchedulingClass = "idle";
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
}
