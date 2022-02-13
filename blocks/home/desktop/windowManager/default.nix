{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.desktop.windowManager;
in
{
  options.blocks.desktop.windowManager = with types; {
    enable = mkOpt bool false;
    name = mkOpt (uniq str) "";
  };

  config = mkIf cfg.enable {
    assertions = [ {
      assertion = cfg.name != ""; 
      message = "no window manager set";
    }];
  };
}
