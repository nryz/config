{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.desktop;
in
{
  options.blocks.desktop = with types; {
    enable = mkOpt bool false;

    extraInit = mkOpt lines "";

    windowManager = {
      pkg = mkOpt' package;
      backend = mkOpt (enum ["wayland" "x"]) "x";
      command = mkOpt lines "";
    };

    background = mkOpt' str;

    font = mkOpt' (nullOr my.libs.hm.types.fontType);

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
  
    blocks.desktop = let
      x = cfg.windowManager.backend == "x";
      wmPkg = cfg.windowManager.pkg;
      pkgBin = "${wmPkg}/bin/${wmPkg.meta.mainProgram}";
    in {
      xserver.enable = x;
      wayland.enable = !x;

      windowManager.command = mkIf x ''exec ${pkgBin}'';
    };

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
      assertion = cfg.windowManager.pkg != {};
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