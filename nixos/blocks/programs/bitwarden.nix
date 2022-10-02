{ config, lib, pkgs, stablePkgs, ... }:

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
    blocks.persist.userDirectories = [ 
      ".config/Bitwarden"
    ];

    hm.home.packages = with pkgs; [
      bitwarden
    ];
  };
}
