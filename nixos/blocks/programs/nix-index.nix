{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.programs.nix-index;
in
{
  options.blocks.programs.nix-index = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    my.state.user.directories = [
      ".cache/nix-index"
    ];

    hm.programs.nix-index = {
      enable = true;
      enableZshIntegration = config.blocks.shell.zsh.enable;
      enableBashIntegration = config.blocks.shell.bash.enable;
      enableFishIntegration = config.blocks.shell.fish.enable;
    };
  };
}

