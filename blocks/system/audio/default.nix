{ config, lib, pkgs, ... }:

{
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
    extraConfig = "
        load-module module-switch-on-connect
        load-module module-bluez5-discover
        load-module module-bluetooth-policy
        load-module module-bluetooth-discover
    ";
  };

  services.tlp = {
    enable = true;
    settings = {
        USB_AUTOSUSPEND = 0;
    };
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
  ];
}
