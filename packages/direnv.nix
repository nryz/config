{ pkgs, my, ... }:

let
    configFile = ''
			 source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
    '';

in my.lib.wrapPackageJoin {
  pkg = pkgs.direnv;
  name = "direnv";

  vars = { 
    "XDG_CONFIG_HOME" = "${placeholder "out"}/config";
  };

  files = {
    "config/direnv/direnvrc" = pkgs.writeText "direnvrc" configFile;
  };
}
