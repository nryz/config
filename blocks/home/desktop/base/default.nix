{ config, lib, pkgs, flakePath, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.desktop;
in
{
  options.blocks.desktop = with types; {
    windowManager = {
      enable = mkOpt bool true;
      name = mkOpt (uniq str) "";
    };

    displayServer = with types; {
      enable = mkOpt bool false;
      backend = mkOpt (uniq str) "";
    };
    
    enable = mkOpt bool false;

    background = mkOpt' str;

    colourscheme = mkOpt' str;

    font = mkOpt' (nullOr hm.types.fontType);

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
  
    systemd.user.targets.graphical-session = {
      UnitConfig = {
        RefuseManualStart = false;
        StopWhenUnneeded = false;
      };
    };

    assertions = [ {
      assertion = cfg.displayServer.backend != ""; 
      message = "no display server set, did you forget to set a window manager?";
    }
    {
      assertion = cfg.windowManager.name != "" || cfg.windowManager.enable == false;
      message = "no window manager set";
    }];

    gtk = {
      enable = true;

      theme = cfg.gtk;
      iconTheme = cfg.gtkIcon;
      font = cfg.font;

      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    };
    
    fonts.fontconfig.enable = true;
  };
}