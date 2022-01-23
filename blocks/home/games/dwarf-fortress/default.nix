{ config, lib, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [ 
    ( dwarf-fortress-packages.dwarf-fortress-full.override {
      theme = dwarf-fortress-packages.themes.wanderlust;
      enableFPS = true;
    })
  ];
}
