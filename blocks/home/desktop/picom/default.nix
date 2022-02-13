{ config, lib, pkgs, extraPkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.desktop.picom;
in
{
  options.blocks.desktop.picom = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {

    services.picom = {
      enable = true;
      backend = "glx";
      vSync = true;
      experimentalBackends = true;

      blur = true; 
      shadow = true;
      shadowOpacity = "0.8";

      extraOptions = ''
        unredir-if-possible = true;

        corner-radius = "0";
        blur-method = "dual_kawase";
        blur-strength = 8;
        xinerama-shadow-crop = true;
      '';

      package = extraPkgs.picom-ibhagwan;
    };
  };
}
