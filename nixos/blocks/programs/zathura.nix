{ config, lib, pkgs, base16, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.zathura;
in
{
  options.blocks.programs.zathura = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.programs.zathura = {
      enable = true;

      extraConfig = '' '' + builtins.readFile (config.scheme base16.zathura);
    };
  };
}
