{ config, lib, pkgs, flakePath, ...}:

with lib;
with lib.my;
let
  cfg = config.blocks.desktop.xserver;
in
{
  options.blocks.desktop.xserver = with types; {
    enable = mkOpt bool false;

    importedVariables = mkOpt (listOf str) [];

    wmCommand = mkOpt lines "";
  };

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/x11/display-managers/default.nix
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/x11/xserver.nix
  # https://github.com/nix-community/home-manager/blob/master/modules/xsession.nix
  config = mkIf cfg.enable {

    blocks.desktop.picom.enable = true;
    blocks.desktop.displayServer.enable = true;
    blocks.desktop.displayServer.backend = "x";

    # https://konfou.xyz/posts/nixos-without-display-manager/
    xdg.configFile.".autostart" = {
      executable = true;
      text = ''
        if [ -z "$DISPLAY" ] && [ $TTY == "/dev/tty1" ]; then
          exec startx &> /dev/null
        fi
      '';
    };

    blocks.desktop.xserver.importedVariables = [
      "DBUS_SESSION_BUS_ADDRESS"
      "DISPLAY"
      "SSH_AUTH_SOCK"
      "XAUTHORITY"
      "XDG_DATA_DIRS"
      "XDG_RUNTIME_DIR"
      "XDG_SESSION_ID"
    ];


    home.file.".xinitrc".text = ''
      systemctl --user import-environment ${toString (unique cfg.importedVariables)} &
      
      systemctl --user start graphical-session.target &

      export XDG_SESSION_TYPE=x11

      ${pkgs.feh}/bin/feh --bg-fill --no-fehbg ${flakePath + /data/backgrounds + "/${config.blocks.desktop.background}"} &

      ${config.xsession.initExtra}

      ${cfg.wmCommand}
    '';

    xresources.path = "${config.home.homeDirectory}/.config/.Xresources";

    home.pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 24;
      x11.enable = true;
      x11.defaultCursor = "left_ptr";
    };
  };
}
