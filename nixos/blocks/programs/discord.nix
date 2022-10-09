{ config, lib, libs, pkgs, ... }:

with lib;
with libs.flake;
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
