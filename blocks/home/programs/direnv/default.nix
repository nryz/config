{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.direnv;
in
{
  options.blocks.programs.direnv = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.directories = [
      ".local/share/direnv"
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
