{ inputs }:

let
  mkLib = lib: rec {
    configurations = import ./configurations.nix { inherit lib inputs; };
    inherit (configurations) mkNixoses mkHomes collectMachines;

    options = import ./options.nix { inherit lib; };
    inherit (options) mkOpt mkOpt' mkOptColour mkOptColour';

    blocks = import ./blocks.nix { inherit lib; };
    inherit (blocks) collectBlocks collectBlocksToList;
  };
in
  inputs.nixpkgs.lib.extend (final: prev: {
    my = mkLib final;
    hm = inputs.home-manager.lib.hm;
  })
