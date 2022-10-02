{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.games.minecraft;
in
{
  options.blocks.games.minecraft = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.home.packages = with pkgs; [ minecraft ];
  };
}
