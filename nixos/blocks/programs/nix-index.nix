{ config, lib, libs, pkgs, ... }:

with lib;
with libs.flake;
let
  cfg = config.blocks.programs.nix-index;
in
{
  options.blocks.programs.nix-index = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.userDirectories = [
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

