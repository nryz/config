{ config, lib, pkgs, ... }:

with lib;
with lib.my;
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
