{
  nixosModules,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    nixosModules.rpi4-profile
    ./hardware-configuration.nix
    ./disk-configuration.nix
  ];

  networking.hostName = "telas";

  time.timeZone = "Europe/London";

  host-scripts.type = "server";

  users.mutableUsers = true;
  users.users.nr = {
    shell = config.mypkgs.zsh;

    packages = with config.mypkgs; [
      git
      helix
      ssh
    ];
  };
}
