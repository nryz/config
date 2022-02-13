{ config, lib, pkgs, inputs, systemInfo, ... }: 

with lib;
with lib.my;
let
  sa = systemInfo.scalability;
in {
  time.timeZone = "Europe/London";

  blocks = mkMerge [({
    autologin = {
      enable = true;
      user = "nr";
    };

    theme.colour = "helios";

    persist.enable = true;
    xserver.enable = true;

    network.enable = true;
    audio.enable = true;
    bluetooth.enable = true;

    services.ssh.enable = true;

  }) 
  (mkIf systemInfo.hardware.nvidia { 
    hardware.nvidia.enable = true; 
  })
  (mkIf systemInfo.hardware.ssd { 
    hardware.ssd.enable = true; 
  })
  (mkIf (sa.diskSpace > 1 && sa.gpu > 1 && sa.cpu > 1) {
    virtualisation.enable = false;
    virtualisation.users = [ "nr" ];
  })];
}

