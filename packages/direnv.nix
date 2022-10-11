{ pkgs, my, ... }:

let
    configFile = pkgs.writeText "direnvrc" ''
			 source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
    '';

in my.lib.wrapPackageJoin {
  pkg = pkgs.direnv;
  name = "direnv";

  vars = { 
    "XDG_CONFIG_HOME" = "${placeholder "out"}/config";
  };

  files = {
    "direnvrc" = {
      path = "config/direnv";
      src = configFile;
    };
  };
}
