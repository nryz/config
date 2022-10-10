{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.programs.fzf;
in
{
  options.blocks.programs.fzf = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.programs.fzf = {
      enable = true;
      enableZshIntegration = config.blocks.shell.zsh.enable;
      enableBashIntegration = config.blocks.shell.bash.enable;
      enableFishIntegration = config.blocks.shell.fish.enable;
    };
  };
}
