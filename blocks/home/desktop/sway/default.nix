{ config, lib, pkgs, extraPkgs, systemInfo, ... }:

{
  wayland.windowManager.sway = {
    enable = true;

    systemdIntegration = true;

    extraSessionCommands = ''
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=sway

      export MOZ_ENABLE_WAYLAND="1"
      
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
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

      menu = "${extraPkgs.sway-launcher-desktop}/bin/sway-launcher-desktop";

      window = {
        border = config.theme.wm.border;
      };

      floating = {
        border = config.theme.wm.border;
      };

      gaps = {
        bottom = config.theme.wm.gap;
        top = config.theme.wm.gap;
        left = config.theme.wm.gap;
        right = config.theme.wm.gap;
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

  programs.waybar = lib.mkIf config.theme.wm.bar.enable {
    enable = true;
    systemd.enable = true;
    systemd.target = "sway-session.target";

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = config.theme.wm.bar.size;
        output = [ systemInfo.hardware.primaryDisplay.name ];

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
}
