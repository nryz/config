{ lib }:

let
  options = import ./options.nix { inherit lib; };
  collect = import ./collect.nix { inherit lib; };
  packages = import ./packages.nix { inherit lib; };
  misc = import ./misc.nix { inherit lib; };

in  options // collect // packages // misc
