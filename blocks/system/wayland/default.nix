{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.wayland;
  extraEnv = { WLR_NO_HARDWARE_CURSORS = "1"; };
in
{
  options.blocks.wayland = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    programs.xwayland.enable = true;
    environment.variables = extraEnv;
    environment.sessionVariables = extraEnv;
    environment.systemPackages = with pkgs; [
      glxinfo
      vulkan-tools
      glmark2
    ];
  };
}
