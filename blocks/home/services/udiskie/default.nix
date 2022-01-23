{ config, lib, pkgs, ... }:

{
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
  };

  home.packages = with pkgs; [
    udiskie
  ];
}
