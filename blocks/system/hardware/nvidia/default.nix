{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.hardware.nvidia;
in
{
  options.blocks.hardware.nvidia = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = ["nvidia"];
    hardware.opengl.enable = true;
    hardware.nvidia.modesetting.enable = true;
    environment.systemPackages = with pkgs; [
      egl-wayland
    ];
  };
}
