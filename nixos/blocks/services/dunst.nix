{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.services.dunst;
in
{
  options.blocks.services.dunst = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.services.dunst = {
      enable = true;

      settings = with my.theme.base16.withHashtag; {
        global = {
          font = "Fira Code 9";
          geometry = "300x5-30+50";
          transparency = 0;
          frame_color = base09;
          separator_color = base09;
          timeout = 3;
        };

        urgency_low = {
          background = base00;
          foreground = base05;
        };

        urgency_normal = {
          background = base00;
          foreground = base05;
        };

        urgency_critical = {
          background = base00;
          foreground = base05;
        };

      };
    };
  };
}
