{ pkgs, my, wrapPackage, ... }:

let
    configFile = ''
			 source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
    '';

in wrapPackage {
  pkg = pkgs.direnv;
  name = "direnv";

  vars = { 
    "XDG_CONFIG_HOME" = "${placeholder "out"}/config";
  };

  files = {
    "config/direnv/direnvrc" = configFile;
  };
}
