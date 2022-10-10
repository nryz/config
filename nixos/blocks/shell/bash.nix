{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.shell.bash;
in
{
  options.blocks.shell.bash = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    my.state.user.files = [ ".bash_history" ];

    hm.programs.bash.enable = true;
  };
}
