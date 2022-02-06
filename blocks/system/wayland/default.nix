{ config, lib, pkgs, ... }:

let
  extraEnv = { WLR_NO_HARDWARE_CURSORS = "1"; };
in
{
  environment.variables = extraEnv;
  environment.sessionVariables = extraEnv;
  environment.systemPackages = with pkgs; [
    glxinfo
    vulkan-tools
    glmark2
  ];

  services.xserver = {
    displayManager.gdm.wayland = true;
    displayManager.gdm.nvidiaWayland = true;
  };
}
