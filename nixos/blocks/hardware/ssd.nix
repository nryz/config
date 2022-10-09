{ config, lib, libs, pkgs, ... }:

with lib;
with libs.flake;
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
