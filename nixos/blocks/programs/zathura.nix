{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.programs.zathura;
in
{
  options.blocks.programs.zathura = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.programs.zathura = {
      enable = true;

    };
  };
}
