{ config, options, lib, pkgs, extraPkgs, inputs, flakePath, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.xserver;
in
{
  options.blocks.xserver = with types; {
    enable = mkOpt bool false;
  };

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
  };
}
