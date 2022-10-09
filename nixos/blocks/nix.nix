{ config, lib, libs, pkgs, info, ... }:

with lib;
with libs.flake;
let
  cfg = config.blocks.nix;
in
{
  options.blocks.nix = with types; {
    enable = mkOpt bool true;
  };
  
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nix-tree
    ];
    
    nix = {
      generateRegistryFromInputs = true;
      generateNixPathFromInputs = true;
      linkInputs = true;
      
      #custom templates
      registry.init = {
       from = { id = "init"; type = "indirect"; };
       to = { owner = "nryz"; repo = "flakeTemplates"; type = "github"; };
      };
      
      # package = pkgs.nixFlakes;
      package = pkgs.nixUnstable;
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
