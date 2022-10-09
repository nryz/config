{ config, lib, libs, pkgs, ... }:

with lib;
with libs.flake;
let
  cfg = config.blocks.desktop;
in
{
  options.blocks.desktop = with types; {
    enable = mkOpt bool false;

    extraInit = mkOpt lines "";

    windowManager = {
      name = mkOpt (uniq str) "";
    };

    background = mkOpt' str;

    colourscheme = mkOpt' str;

    font = mkOpt' (nullOr libs.hm.types.fontType);

    gtk = {
      package = mkOpt' (nullOr package);
      name = mkOpt' str;
    };

    gtkIcon = {
      package = mkOpt' (nullOr package);
      name = mkOpt' str;
    };
  };

  config = mkIf cfg.enable {
  
    blocks.programs.rofi.enable = true;
  
    hm.systemd.user.targets.graphical-session = {
      UnitConfig = {
        RefuseManualStart = false;
        StopWhenUnneeded = false;
      };
    };

    assertions = [ {
      assertion = config.blocks.desktop.xserver.enable || config.blocks.desktop.wayland.enable; 
      message = "no display server set, did you forget to set a window manager?";
    }
    {
      assertion = cfg.windowManager.name != "";
      message = "no window manager set";
    }];

    hm.gtk = {
      enable = true;

      theme = cfg.gtk;
      iconTheme = cfg.gtkIcon;
      font = cfg.font;

      gtk2.configLocation = "${config.hm-read-only.xdg.configHome}/gtk-2.0/gtkrc";
    };
    
    hm.fonts.fontconfig.enable = true;
  };
}