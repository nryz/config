{ config, lib, pkgs, extraPkgs, ... }:

{
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
}
