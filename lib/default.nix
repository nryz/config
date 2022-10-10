{ pkgs }:

let
  lib = pkgs.lib;
  
  configurations = import ./configurations.nix { inherit pkgs lib; };
  options = import ./options.nix { inherit pkgs lib; };
  blocks = import ./blocks.nix { inherit pkgs lib; };
  packages = import ./packages.nix { inherit pkgs lib; };
in {
  inherit (configurations) collectMachines;
  inherit (blocks) collectBlocks;
  inherit (options) mkOpt mkOpt' mkOptColour mkOptColour';
  inherit (packages) wrapPackage wrapPackageJoin;
}
