{
  inputs,
  system,
  ...
}: let
  pkgs = import inputs.nixpkgs {inherit system;};
  lib = pkgs.lib;
in {
  rust = import ./rust {inherit pkgs lib inputs;};
}
