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
