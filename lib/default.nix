{ pkgs }:

let
  lib = pkgs.lib;
  
  options = import ./options.nix { inherit pkgs lib; };
  collect = import ./collect.nix { inherit pkgs lib; };
  packages = import ./packages.nix { inherit pkgs lib; };
in  options // collect // packages
