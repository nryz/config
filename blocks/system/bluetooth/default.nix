{ config, lib, pkgs, ... }:

{
  persist.directories = [ "/var/lib/bluetooth" ];

  hardware.bluetooth = {
      enable = true;
      settings.General.Enable = "Source,Sink,Media,Socket";
  };
  services.blueman.enable = true;
  services.dbus.packages = with pkgs; [ blueman ];
}
