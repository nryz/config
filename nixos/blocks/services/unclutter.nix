{ config, lib, libs, pkgs, ... }:

with lib;
with libs.flake;
let
  cfg = config.blocks.services.unclutter;
in
{
  options.blocks.services.unclutter = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.services.unclutter = {
      enable = true;
    };
  };
}
