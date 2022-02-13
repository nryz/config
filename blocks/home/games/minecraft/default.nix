{ config, lib, pkgs, inputs, ... }:

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
    home.packages = with pkgs; [ minecraft ];
  };
}
