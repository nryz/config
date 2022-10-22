{ pkgs }:

let
  lib = pkgs.lib;
  
  configurations = import ./configurations.nix { inherit pkgs lib; };
  options = import ./options.nix { inherit pkgs lib; };
  modules = import ./modules.nix { inherit pkgs lib; };
  packages = import ./packages.nix { inherit pkgs lib; };
in configurations // options // modules // packages
