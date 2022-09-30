{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.git;
in
{
  options.blocks.programs.git = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;

      userEmail = "mail@nryz.xyz";
      userName = "nryz";
    };

    home.packages = with pkgs; [
      gitui
    ];
  };
}
