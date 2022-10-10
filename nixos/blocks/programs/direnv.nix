{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.programs.direnv;
in
{
  options.blocks.programs.direnv = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    my.state.user.directories = [
      ".local/share/direnv"
    ];

    hm.programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
