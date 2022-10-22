{ self, system }:

let
	inputs = self.inputs;

	pkgs = import inputs.nixpkgs { 
		inherit system; 
    overlays = [  inputs.nur.overlay  ];
	};
	
	lib = pkgs.lib;

  naersk = pkgs.callPackage inputs.naersk {};

	my.pkgs = self.packages.${system};
  my.lib = import ../lib { inherit pkgs; };
	
	args = with my.lib; rec { 
		inherit inputs pkgs my; 

		base16 = (pkgs.callPackage inputs.base16 {}).mkSchemeAttrs ../content/base16/solarized-dark.yaml;

		terminal = mkDefPkg my.pkgs.kitty;
		editor = mkDefPkg my.pkgs.helix;
		browser = mkDefPkg my.pkgs.qutebrowser;
		
		background = ../content/backgrounds/4;

		# TODO: make this work for all applications
		cursor.package = pkgs.vanilla-dmz;
		cursor.name = "Vanilla-DMZ";
		cursor.size = 16;

	  font.package = pkgs.source-code-pro;
	  font.name = "Source Code Pro";
	  font.size = 9;
		
		xdg = {
			cacheHome = "$HOME/.cache";
		  configHome = "$HOME/.config";
		  dataHome = "$HOME/.local/share";
		  stateHome = "$HOME/.local/state";
		};
		
		wrapPackage = args: my.lib.wrapPackage ({
			prefix = {
				"XDG_DATA_DIRS" = [ ":" "${my.pkgs.theme}/share"];
				"XCURSOR_PATH" = [ ":" "${my.pkgs.theme}/share/icons"];
			};
		} // args);
	};

	callPackage = pkgs.newScope args;	
	
	gtk = import ./gtk-functions.nix args;
in (with pkgs; gtk.wrapGtkPackages [
	blueberry
	gucharmap
	xfce.thunar
	filezilla
	gnome.nautilus
	dolphin
	lxappearance
]) // {

	lf = 						callPackage ./lf.nix {};
	mpv = 					callPackage ./mpv.nix {};
	imv = 					callPackage ./imv.nix {};
	git = 					callPackage ./git.nix {};
	zsh = 					callPackage ./shell/zsh.nix {};
	ssh = 					callPackage ./ssh.nix {};
	btop = 					callPackage ./btop.nix {};
	rofi = 					callPackage ./rofi.nix {};
  kitty = 				callPackage ./kitty.nix {};
	dunst = 				callPackage ./dunst.nix {};
  helix = 				callPackage ./helix.nix {};
	theme = 				callPackage ./theme.nix {};
  picom = 				callPackage ./picom.nix {};
	startx =				callPackage ./wm/startx.nix {};
	direnv = 				callPackage ./direnv.nix {};
	zathura = 			callPackage ./zathura.nix {};
	firefox = 			callPackage ./firefox.nix {};
	unclutter = 		callPackage ./unclutter.nix {};
  qutebrowser = 	callPackage ./qutebrowser.nix {};
	herbstluftwm = 	callPackage ./wm/herbstluftwm.nix {};
	
	all = let
		all-pkgs = builtins.filter (x: x.name != "all")
			(lib.mapAttrsToList (n: v: v) my.pkgs);
	in pkgs.linkFarmFromDrvs "all" all-pkgs;
	
}
