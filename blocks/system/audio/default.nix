{ config, lib, pkgs, ... }:

{
 persist.directories = ["/var/lib/alsa"];
 persist.userDirectories = [".config/pulse" ];

 #pulseaudio
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

 #security.rtkit.enable = true;
 #services.pipewire = {
 #  enable = true;
 #  alsa.enable = true;
 #  alsa.support32Bit = true;
 #  pulse.enable = true;
 #  media-session.enable = false;
 #  wireplumber.enable = true;
 #};


 services.tlp = {
   enable = true;
   settings = {
     USB_AUTOSUSPEND = 0;
   };
 };

 environment.systemPackages = with pkgs; [
   pavucontrol
   pamixer
   (pkgs.writeScriptBin "ToggleVolume" ''
      #!/usr/bin/env bash
      pamixer -t
    '')
   (pkgs.writeScriptBin "IncreaseVolume" ''
      #!/usr/bin/env bash
      pamixer -i 5
    '')
   (pkgs.writeScriptBin "DecreaseVolume" ''
      #!/usr/bin/env bash
      pamixer -d 5
    '')
   (pkgs.writeScriptBin "GetVolume" ''
      #!/usr/bin/env bash
      pamixer --get-volume-human
    '')
 ];
}
