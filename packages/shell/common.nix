{ pkgs, xdg }:

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
				fzf
			]));
	};

	aliases = {
    "cat" = "${pkgs.bat}/bin/bat";
    "lsd" = "${pkgs.lsd}/bin/lsd --group-directories-first -1";
    "rg" = "${pkgs.ripgrep}/bin/rg --no-messages";
    "tree" = "tree --dirsfirst";
	};
	
	variables = {
	  "EDITOR" = "hx";
    "VISUAL" = "hx";
    "LOCALE_ARCHIVE_2_27" = "${pkgs.glibcLocales}/lib/locale/locale-archive";
	};
	
	defaultVariables = ''
	  : ''${XDG_CACHE_HOME:="${xdg.cacheHome}"}
	  : ''${XDG_CONFIG_HOME:="${xdg.configHome}"}
	  : ''${XDG_DATA_HOME:="${xdg.dataHome}"}
	  : ''${XDG_STATE_HOME:="${xdg.stateHome}"}
		
		export XDG_CACHE_HOME
		export XDG_CONFIG_HOME
		export XDG_STATE_HOME
		export XDG_DATA_HOME
	'';
}
