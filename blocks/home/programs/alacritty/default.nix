{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.alacritty;
in
{
  options.blocks.programs.alacritty = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;

      settings = {

        font = {
          size = 10;
        };

        window = {
          padding = {
            x = 0;
            y = 0;
          };
        };

        colors = with config.scheme.withHashtag; let default = {
            black = base00; white = base07;
            inherit red green yellow blue cyan magenta;
          };
        in {
          primary = { background = base00; foreground = base07; };
          cursor = { text = base02; cursor = base07; }; 
          normal = default; bright = default; dim = default;
        };
      };
    };
  };
}
