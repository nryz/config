{ self, system, colour }:

let
	inputs = self.inputs;

	pkgs = import inputs.nixpkgs { 
		inherit system; 
    overlays = [  inputs.nur.overlay  ];
	};
	
	lib = pkgs.lib;
	

  naersk = pkgs.callPackage inputs.naersk {};
	base16 = pkgs.callPackage inputs.base16 {};

	my.pkgs = self.packages.${system};
  my.lib = import ../lib { inherit pkgs; };

	callPackage = with my.lib; pkgs.newScope { 
		inherit inputs pkgs my; 

		base16 = base16.mkSchemeAttrs colour;

	  font.package = pkgs.source-code-pro;
	  font.name = "Source Code Pro";
	  font.size = 9;
	
		terminal = mkDefPkg my.pkgs.kitty;
		editor = mkDefPkg my.pkgs.helix;
	};
	
in
{
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
	river = 				callPackage ./wm/river.nix {};
  picom = 				callPackage ./picom.nix {};
	direnv = 				callPackage ./direnv.nix {};
	zathura = 			callPackage ./zathura.nix {};
	firefox = 			callPackage ./firefox.nix {};
	unclutter = 		callPackage ./unclutter.nix {};
  zsh-vi-mode = 	callPackage ./zsh-vi-mode.nix { src = inputs.zsh-vi-mode; };
  qutebrowser = 	callPackage ./qutebrowser.nix {};
	herbstluftwm = 	callPackage ./wm/herbstluftwm.nix {};
	
	all = let
		all-pkgs = builtins.filter (x: x.name != "all")
			(lib.mapAttrsToList (n: v: v) my.pkgs);
	in pkgs.linkFarmFromDrvs "all" all-pkgs;
	
}
