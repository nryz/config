{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.games.lutris;
in
{
  options.blocks.games.lutris = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.home.packages = with pkgs; [ lutris ];
  };
}
