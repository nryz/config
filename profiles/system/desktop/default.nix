{ config, lib, pkgs, inputs, blocks, systemInfo, ... }: 
let
  sa = systemInfo.scalability;
in {

  imports = with blocks; [
    persist
    xserver

    #todo
    hardware.monitor

    network
    audio
    bluetooth
    services.ssh

  ] ++ lib.optionals (systemInfo.hardware.nvidia) [ 
    hardware.nvidia 
  ] ++ lib.optionals (systemInfo.hardware.ssd) [ 
    hardware.ssd 
  ] ++ lib.optionals (sa.diskSpace > 1 && sa.gpu > 1 && sa.cpu > 1) [
   # virtualisation { virtualisation.users = [ "nr" ]; }
  ];

  time.timeZone = "Europe/London";
  autoLoginUser = "nr";

  theme = {
    background = "8";
  };
}

