{ config, lib, pkgs, inputs, defaultUser, ... }: 

with lib;
with lib.my;
{
  time.timeZone = "Europe/London";

  blocks = {
    autologin = {
      enable = true;
      user = "${defaultUser}";
    };

    displayServer.enable = true;

    colourscheme = "helios";

    persist.enable = true;

    network.enable = true;
    audio.enable = true;
    bluetooth.enable = true;

    services.ssh.enable = true;

    hardware.nvidia.enable = true; 
    hardware.ssd.enable = true; 
    virtualisation.enable = false;
    virtualisation.users = [ defaultUser ];
    
    # xremap.enable = false;
  };
}

