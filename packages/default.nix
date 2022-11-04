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
		inherit naersk;

		base16 = (pkgs.callPackage inputs.base16 {}).mkSchemeAttrs ../content/base16/solarized-dark.yaml;

		terminal = mkDefPkg {
			pkg = my.pkgs.alacritty;
			desktop = "Alacritty.desktop"; 
		};

		editor = mkDefPkg {
			pkg = my.pkgs.helix;
			desktop = "Helix.desktop";
		};

		browser = mkDefPkg {
			pkg = my.pkgs.qutebrowser;
			desktop = "org.qutebrowser.qutebrowser.desktop";
		};
		
		imageViewer = mkDefPkg {
			pkg = my.pkgs.imv;
			desktop = "imv.desktop";
		};
		
		videoPlayer = mkDefPkg {
			pkg = my.pkgs.imv;
			desktop = "mpv.desktop";
		};
		
		pdfViewer = mkDefPkg {
			pkg = my.pkgs.zathura;
			desktop = "org.pwmt.zathura.desktop";
		};
		
		background = ../content/backgrounds/2;

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
		
		wrapPackage = args: my.lib.wrapPackage (args // {
			share = [ my.pkgs.theme ] ++ 
				lib.optionals (args ? share) args.share;
			prefix = { "XCURSOR_PATH" = [ ":" "${my.pkgs.theme}/share/icons"]; } // 
				lib.optionalAttrs (args ? prefix) args.prefix;
		});
		
		nix-index-database = inputs.nix-index-database.legacyPackages.${system}.database;
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

	alacritty = callPackage ./alacritty.nix {};
	bottom = callPackage ./bottom.nix {};
	direnv = callPackage ./direnv.nix {};
	dunst = callPackage ./dunst.nix {};
	firefox = callPackage ./firefox.nix {};
	git = callPackage ./git.nix {};
	gitui = callPackage ./gitui.nix {};
  helix = callPackage ./helix.nix {};
	herbstluftwm = callPackage ./wm/herbstluftwm.nix {};
	imv = callPackage ./imv.nix {};
	joshuto = callPackage ./joshuto.nix {};
  kitty = callPackage ./kitty.nix {};
	mimeapps = callPackage ./mimeapps.nix {};
	mpv = callPackage ./mpv.nix {};
	nix-index = callPackage ./nix-index.nix {};
  picom = callPackage ./picom.nix {};
  qutebrowser = callPackage ./qutebrowser.nix {};
	rofi = callPackage ./rofi.nix {};
	startx = callPackage ./wm/startx.nix {};
	ssh = callPackage ./ssh.nix {};
	theme = callPackage ./theme.nix {};
	unclutter = callPackage ./unclutter.nix {};
	yambar = callPackage ./wm/yambar.nix {};
	zathura = callPackage ./zathura.nix {};
	zsh = callPackage ./shell/zsh.nix {};
	
	all = let
		all-pkgs = builtins.filter (x: x.name != "all")
			(lib.mapAttrsToList (n: v: v) my.pkgs);
	in pkgs.linkFarmFromDrvs "all" all-pkgs;
	
}
