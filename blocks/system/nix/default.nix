{ config, lib, pkgs, configPath, ... }:

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
      
      #custom templates
      registry.init = {
       from = { id = "init"; type = "indirect"; };
       to = { owner = "nryz"; repo = "flakeTemplates"; type = "github"; };
      };
      
      registry.system = {
        from = { id = "system"; type = "indirect"; };
        to = { path = "${configPath}"; type = "path"; };
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
