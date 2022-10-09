{ config, lib, libs, pkgs, ... }:

with lib;
with libs.flake;
let
  cfg = config.blocks.shell.bash;
in
{
  options.blocks.shell.bash = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.userFiles = [ ".bash_history" ];

    hm.programs.bash.enable = true;
  };
}
