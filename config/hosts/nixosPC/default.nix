{ config, lib, pkgs, inputs, blocks, ... }:

{
  imports = with blocks; [
    profiles.desktop { theme = {
      background = "11";
      colorscheme = "gruvbox-dark-soft";
    }; }

    xserver

    hardware.ssd
    hardware.nvidia
    hardware.monitor

    network
    audio
    bluetooth

   # virtualisation { virtualisation.users = [ "nr" ]; }

    services.ssh
  ];

  home.users.nr = {
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    config = import ./nr.nix;
  };
}

