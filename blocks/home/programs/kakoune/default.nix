{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.kakoune;
in
{
  options.blocks.programs.kakoune = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    xdg.configFile."kak/colors/base16-scheme.kak".text = 
      builtins.readFile (config.scheme inputs.base16-kakoune);

    programs.kakoune = {
      enable = true;

      config = {
        colorScheme = "base16-scheme";
      };
    };
  };
}
