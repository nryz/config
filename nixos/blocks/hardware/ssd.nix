{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.hardware.ssd;
in
{
  options.blocks.hardware.ssd = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    services.fstrim.enable = true;
  };
}
