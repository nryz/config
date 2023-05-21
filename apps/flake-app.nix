{ self, system, pkgs } :
let
  lib = self.inputs.nixpkgs.lib;
in {
  update = (pkgs.writeShellScriptBin "flake-update" ''
      nix flake update
  '');
}
