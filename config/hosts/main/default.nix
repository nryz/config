{ config, lib, pkgs, inputs, blocks, ... }: {

  imports = with blocks; [
    profiles.desktop { theme = {
      background = "8";
    }; }

    xserver { autoLoginUser = "nr"; }

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
    config = import ./home.nix;
  };
}

