{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.services.unclutter;
in
{
  options.blocks.services.unclutter = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    services.unclutter = {
      enable = true;
    };
  };
}
