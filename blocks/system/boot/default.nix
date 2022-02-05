{ config, lib, pkgs, ... }:

{
  boot = {
    #kernelPackages = pkgs.linuxPackages_latest;

    loader =  {
      timeout = 1;
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        consoleMode = "auto";
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
  };
}
