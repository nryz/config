{ config, options, pkgs, lib, my, ... }:
let
  stateVersion = "21.11";
in
{
  networking.hostName = my.hostName;

  time.hardwareClockInLocalTime = true;

  system.stateVersion = stateVersion;

  nixpkgs.config = pkgs.config;
  nixpkgs.pkgs = pkgs;

  users.mutableUsers = false;

  users.users.nr = {
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    passwordFile = "/nix/passwords/nr";
    uid = 1000;
  };

  users.users.root.hashedPassword = "!";

  nix.generateRegistryFromInputs = true;
  nix.generateNixPathFromInputs = true;
  nix.linkInputs = true;
  nix.package = pkgs.nixUnstable;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    warn-dirty = false
    allow-dirty = true
    keep-outputs = true
    keep-derivations = true
  '';

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 10d";
  nix.settings.auto-optimise-store = true;
}
