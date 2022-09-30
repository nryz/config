{ config, lib, pkgs, stablePkgs, inputs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.bitwarden;
in
{
  options.blocks.programs.bitwarden = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.directories = [ 
      ".config/Bitwarden"
    ];

    home.packages = with pkgs; [
      bitwarden
    ];
  };
}
