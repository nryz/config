{ config, lib, pkgs, stablePkgs, inputs, ... }:

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
    programs.zathura = {
      enable = true;

      extraConfig = '' '' + builtins.readFile (config.scheme inputs.base16-zathura);
    };
  };
}
