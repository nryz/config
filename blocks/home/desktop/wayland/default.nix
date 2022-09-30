{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.desktop.wayland;
in
{
  options.blocks.desktop.wayland = with types; {
    enable = mkOpt bool false;
    wmCommand = mkOpt lines "";
  };

  config = mkIf cfg.enable {
    blocks.desktop.displayServer.enable = true;
    blocks.desktop.displayServer.backend = "wayland";

    home.packages = with pkgs; [
      swaybg
    ];

    home.sessionVariables = {
        LIBSEAT_BACKEND = "logind";
        SDL_VIDEODRIVER = "wayland";
        _JAVA_AWT_WM_NONREPARENTING = 1;
        XDG_SESSION_TYPE = "wayland";
        MOZ_ENABLE_WAYLAND = 1;
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
        QT_SCALE_FACTOR = 1;
        GDK_BACKEND = "wayland";
    };

    xdg.configFile.".autostart" = {
      executable = true;
      text = ''
        if [ -z "$DISPLAY" ] && [ $TTY == "/dev/tty1" ]; then
          ${cfg.wmCommand}
        fi
      '';
    };

  };
}
