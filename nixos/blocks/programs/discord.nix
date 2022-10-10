{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.programs.discord;
in
{
  options.blocks.programs.discord = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      discord
    ];
  };
}
