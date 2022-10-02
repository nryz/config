{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.services.udiskie;
in
{
  options.blocks.services.udiskie = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.services.udiskie = {
      enable = true;
      automount = true;
      notify = true;
    };

    hm.home.packages = with pkgs; [
      udiskie
    ];
  };
}
