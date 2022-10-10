{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
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
