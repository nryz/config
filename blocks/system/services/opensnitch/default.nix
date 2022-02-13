{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.services.opensnitch;
in
{
  options.blocks.services.opensnitch = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.directories = [ "/var/lib/opensnitch" ];
    services.opensnitch.enable = true;
  };
}
