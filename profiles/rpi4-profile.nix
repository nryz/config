{ config, options, pkgs, lib, my, ... }:

{
  imports = [
    ./core-profile.nix
  ];

  boot = {
    loader.grub.enable = false;
    loader.raspberryPi.enable = true;
    loader.raspberryPi.version = 4;

    kernelPackages = pkgs.linuxPackages_rpi4;
    tmp.useTmpfs = true;

    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];

    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      # A lot GUI programs need this, nearly all wayland applications
      "cma=128M"
    ]; 
   };

  hardware.enableRedistributableFirmware = true;
}
