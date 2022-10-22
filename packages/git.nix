{ pkgs, my, wrapPackage, ... }:

with pkgs.lib;
let
    configFile = let 
			difftCommand = concatStringsSep " " [
          "${pkgs.difftastic}/bin/difft"
          "--color always"
          "--background dark"
          "--display side-by-side"
        ];		

		in ''
			[diff]
				external = ${difftCommand}
        tool = difftastic

			[difftool]
        prompt = false

			[difftool "difftastic"]
        cmd = ${difftCommand} "$LOCAL" "$REMOTE"

			[pager]
        difftool = true
		'';

in wrapPackage {
  pkg = pkgs.git;
  name = "git";

  vars = { 
    "XDG_CONFIG_HOME" = "${placeholder "out"}/config";
  };

  files = {
    "config/git/config" = configFile;
  };
}
