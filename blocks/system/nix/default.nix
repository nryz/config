{ config, lib, pkgs, ... }:

{
  nix = {
    generateRegistryFromInputs = true;
    generateNixPathFromInputs = true;
    linkInputs = true;

    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
      allow-dirty = true
      flake-registry = 
    '';

    gc = {
      automatic = true;
      options = "--delete-older-than 5d";
    };

    settings = {
      auto-optimise-store = true;
    };
  };
}
