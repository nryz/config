{ my 
, pkgs
, xdg
, variables
, editor
, shell
}:

with pkgs.lib;
{
	 pkgs = with pkgs; symlinkJoin { 
		name = "shellPkgs"; 
		paths = (flatten (map (x: 
			[x] ++ (optional (builtins.elem "man" x.outputs) [x.man])) 
			[
		    ripgrep
		    lsd
		    bat
		    tree
		    fd
		    sd
				my.pkgs.skim
			]));
	};

	aliases = {
    "lsd" = "${pkgs.lsd}/bin/lsd --group-directories-first -1";
    "rg" = "${pkgs.ripgrep}/bin/rg --no-messages";
    "tree" = "tree --dirsfirst";
		"lsb" = "lsblk -o name,label,type,size,rm,model,serial";
		"ndev" = "nix develop -c ${shell}";
	};
	
	variables = {
	  "EDITOR" = "${editor.name}";
    "VISUAL" = "${editor.name}";
    "LOCALE_ARCHIVE_2_27" = "${pkgs.glibcLocales}/lib/locale/locale-archive";
	} // variables;
	
	defaultVariables = ''
	  : ''${XDG_CACHE_HOME:="${xdg.cacheHome}"}
	  : ''${XDG_CONFIG_HOME:="${xdg.configHome}"}
	  : ''${XDG_DATA_HOME:="${xdg.dataHome}"}
	  : ''${XDG_STATE_HOME:="${xdg.stateHome}"}
		
		export XDG_CACHE_HOME
		export XDG_CONFIG_HOME
		export XDG_STATE_HOME
		export XDG_DATA_HOME

		export FONTCONFIG_FILE=${my.pkgs.fontconfig}
	'';
}
