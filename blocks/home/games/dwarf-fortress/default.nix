{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.games.dwarf-fortress;
in
{
  options.blocks.games.dwarf-fortress = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ 
      ( dwarf-fortress-packages.dwarf-fortress-full.override {
        theme = dwarf-fortress-packages.themes.wanderlust;
        enableFPS = true;
      })
    ];
  };
}
