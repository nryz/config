{ pkgs }:
{
	aliases = {
    "cat" = "${pkgs.bat}/bin/bat";
    "lsd" = "${pkgs.lsd}/bin/lsd --group-directories-first -1";
    "rg" = "${pkgs.ripgrep}/bin/rg --no-messages";
    "tree" = "tree --dirsfirst";
	};
	
	variables = {
	  "EDITOR" = "hx";
    "VISUAL" = "hx";
	};
}
