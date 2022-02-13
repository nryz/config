{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.veracrypt;
in
{
  options.blocks.programs.veracrypt = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      veracrypt
    ];
  };
}
