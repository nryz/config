{
  additionalStorePaths,
  config,
  nixosModules,
  pkgs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    nixosModules.core-profile
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  networking.hostName = "sd-rpi4";

  boot.consoleLogLevel = 0;

  sdImage.storePaths = additionalStorePaths;
  sdImage.compressImage = false;

  # less privileged nixos user
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "video"];
    initialHashedPassword = "";
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = "nixos";

  host-scripts.type = "sdImage";
}
