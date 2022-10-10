{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.programs.filezilla;
in
{
  options.blocks.programs.filezilla = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      filezilla
    ];
  };
}
