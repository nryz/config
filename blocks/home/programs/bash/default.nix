{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.bash;
in
{
  options.blocks.programs.bash = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.files = [ ".bash_history" ];

    programs.bash = {
      enable = true;

    };
  };
}
