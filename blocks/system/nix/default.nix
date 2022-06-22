{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.nix;
in
{
  options.blocks.nix = with types; {
    enable = mkOpt bool false;
  };
  
  config = mkIf cfg.enable {
    nix = {
      generateRegistryFromInputs = true;
      generateNixPathFromInputs = true;
      linkInputs = true;

      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
        warn-dirty = false
        allow-dirty = true
        keep-outputs = true
        keep-derivations = true
      '';

      gc = {
        automatic = true;
        options = "--delete-older-than 5d";
      };

      settings = {
        auto-optimise-store = true;
      };
    };
  };
}
