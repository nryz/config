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
    blocks.persist.userDirectories = [
      ".local/share/direnv"
    ];

    hm.programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
