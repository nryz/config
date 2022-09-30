{ config, lib, pkgs, extraPkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.desktop.sway;
in
{
  options.blocks.desktop.sway = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.desktop.windowManager.name = "sway";
    blocks.desktop.wayland.enable = true;
    blocks.desktop.wayland.wmCommand = ''
      exec sway > $HOME/.config/sway/sway.log 2>&1
    '';

    wayland.windowManager.sway = {
      enable = true;

      extraOptions = [ "--unsupported-gpu" ];

      systemdIntegration = true;

      extraSessionCommands = ''
         export XDG_CURRENT_DESKTOP=sway
      '';

      wrapperFeatures = {
        base = true;
        gtk = true;
      };

      config = {

        focus.followMouse = false;

        terminal = config.defaults.terminal;
        modifier = "Mod4";
        keybindings = let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in lib.mkOptionDefault {
          "${modifier}+u" = "exec ${extraPkgs.sway-launcher-desktop}/bin/sway-launcher-desktop";
          "XF86AudioMute" = "exec ToggleVolume";
          "XF86AudioLowerVolume" = "exec DecreaseVolume";
          "XF86AudioRaiseVolume" = "exec IncreaseVolume";
          "${modifier}+w" = "kill";
        };

        window = {
          border = 2;
        };

        floating = {
          border = 2;
        };

        gaps = {
          bottom = 12;
          top = 12;
          left = 12;
          right = 12;
        };
        
        colors = with config.scheme.withHashtag; {
          background = base07;

          focused = {
            border = base05;
            background = base0D;
            text = base00;
            indicator = base0D;
            childBorder = base0C;
          };

          focusedInactive = {
            border = base01;
            background = base01;
            text = base05;
            indicator = base03;
            childBorder = base01;
          };

          unfocused = {
            border = base01;
            background = base00;
            text = base05;
            indicator = base01;
            childBorder = base01;
          };

          urgent = {
            border = base08;
            background = base08;
            text = base00;
            indicator = base08;
            childBorder = base08;
          };

          placeholder = {
            border = base00;
            background = base00;
            text = base05;
            indicator = base00;
            childBorder = base00;
          };
        };
      };
    };

    home.packages = with pkgs; [
      wl-clipboard
      clipman
    ];

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      systemd.target = "sway-session.target";

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 22;
          output = [ config.systemInfo.hardware.primaryDisplay.name ];

          ipc = true;

          modules-left = [ "sway/workspaces" "sway/mode" ];
          modules-center = [ "clock" ];
          modules-right = [ "pulseaudio" "cpu" "memory" ];

          "sway/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
          };

          "clock" = {
            format-alt = "{:%a, %d. %b %H:%M}";
          };
        };
      };
    };
  };
}
