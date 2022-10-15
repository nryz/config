{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.desktop.xserver;
in
{
  options.blocks.desktop.xserver = with types; {
    enable = mkOpt bool false;
  };

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/x11/display-managers/default.nix
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/x11/xserver.nix
  # https://github.com/nix-community/home-manager/blob/master/modules/xsession.nix
  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      autorun = false;

      layout = "us";
      xkbOptions = "eurosign:e";

      monitorSection = ''
        Option "DPMS" "disable"
      '';

      serverFlagsSection  = ''
        Option "StandbyTime" "0"
        Option "SuspendTime" "0"
        Option "OffTime" "0"
        Option "BlankTime" "0"
      '';

      displayManager.startx.enable = true;
      displayManager.lightdm.enable = mkForce false;
    };

    blocks.desktop.picom.enable = true;

    # https://konfou.xyz/posts/nixos-without-display-manager/
    hm.xdg.configFile.".autostart" = {
      executable = true;
      text = ''
        if [ -z "$DISPLAY" ] && [ $TTY == "/dev/tty1" ]; then
          exec startx &> /dev/null
        fi
      '';
    };

    hm.home.file.".xinitrc".text = let
      importedVariables = [
        "DBUS_SESSION_BUS_ADDRESS"
        "DISPLAY"
        "SSH_AUTH_SOCK"
        "XAUTHORITY"
        "XDG_DATA_DIRS"
        "XDG_RUNTIME_DIR"
        "XDG_SESSION_ID"
      ];
    in ''
      systemctl --user import-environment ${toString (unique importedVariables)} &
      
      systemctl --user start graphical-session.target &

      export XDG_SESSION_TYPE=x11

      ${pkgs.feh}/bin/feh --bg-fill --no-fehbg ${my.flakePath + /content/backgrounds + "/${config.blocks.desktop.background}"} &

      ${config.hm-read-only.xsession.initExtra}
      
      ${config.blocks.desktop.extraInit}

      ${config.blocks.desktop.windowManager.command}
    '';

    hm.xresources.path = "${config.hm.home.homeDirectory}/.config/.Xresources";

    hm.home.pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 24;
      x11.enable = true;
      x11.defaultCursor = "left_ptr";
    };
  };
}
