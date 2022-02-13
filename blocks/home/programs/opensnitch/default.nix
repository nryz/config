{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.opensnitch;
in
{
  options.blocks.programs.opensnitch = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    services.opensnitch-ui.enable = true;
  };
}
