{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.audio;
in
{
  options.blocks.audio = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
   blocks.persist.directories = ["/var/lib/alsa"];
   blocks.persist.userDirectories = [".config/pulse" ];

   #pulseaudio
   sound.enable = true;
   hardware.pulseaudio = {
     enable = true;

     extraConfig = ''
       load-module module-switch-on-connect
     '';
   };

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
  };
}
