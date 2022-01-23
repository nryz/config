
{ config, lib, pkgs, ... }:

{
  programs.nix-index = {
    enable = true;
    enableZshIntegration = config.programs.zsh.enable;
    enableBashIntegration = config.programs.bash.enable;
    enableFishIntegration = config.programs.fish.enable;
  };
}

