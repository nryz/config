{ config, lib, libs, pkgs, ... }:

with lib;
with libs.flake;
let
  cfg = config.blocks.bluetooth;
in
{
  options.blocks.bluetooth = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.directories = [ "/var/lib/bluetooth" ];

    hardware.bluetooth = {
        enable = true;
        disabledPlugins = [ "sap" ];
        settings.General.Enable = "Source,Sink,Media,Socket";
    };
    services.blueman.enable = true;
    services.dbus.packages = with pkgs; [ blueman ];
  };
}
