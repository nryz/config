{ config, lib, pkgs, inputs, ... }:

{
  system.programs = [ "steam" ];

  home.packages = with pkgs; [ 
    steam-tui 
    steam-run-native 
  ];
}
