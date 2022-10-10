{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.bluetooth;
in
{
  options.blocks.bluetooth = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    my.state.directories = [ "/var/lib/bluetooth" ];

    hardware.bluetooth = {
        enable = true;
        disabledPlugins = [ "sap" ];
        settings.General.Enable = "Source,Sink,Media,Socket";
    };
    services.blueman.enable = true;
    services.dbus.packages = with pkgs; [ blueman ];
  };
}
