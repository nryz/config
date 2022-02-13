{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.desktop.displayServer;
in
{
  options.blocks.desktop.displayServer = with types; {
    enable = mkOpt bool false;

    backend = mkOpt (uniq str) "";
  };

  config = mkIf cfg.enable {
    systemd.user.targets.graphical-session = {
      UnitConfig = {
        RefuseManualStart = false;
        StopWhenUnneeded = false;
      };
    };

    assertions = [ {
      assertion = cfg.backend != ""; 
      message = "no window manager set";
    }];
  };
}
