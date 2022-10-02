{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.games.steam;
in
{
  options.blocks.games.steam = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;

    hm.home.packages = with pkgs; [ 
      steam-tui 
      steam-run-native 
    ];
  };
}
