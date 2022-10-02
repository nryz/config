{ config, lib, pkgs, ... }:

with lib;
with lib.my;
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

      settings = with config.scheme.withHashtag; {
        global = {
          font = "Fira Code 9";
          geometry = "300x5-30+50";
          transparency = 10;
          frame_color = base05;
          separator_color = base05;
          timeout = 3;
        };

        urgency_low = {
          background = base01;
          foreground = base03;
        };

        urgency_normal = {
          background = base02;
          foreground = base05;
        };

        urgency_critical = {
          background = base08;
          foreground = base06;
        };

      };
    };
  };
}
