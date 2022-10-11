{ system, inputs, colour }:

let
	pkgs = import inputs.nixpkgs { inherit system; 
    overlays = [  inputs.nur.overlay  ];
	};

  naersk = pkgs.callPackage inputs.naersk {};
	base16 = pkgs.callPackage inputs.base16 {};

  my.lib = import ../lib { inherit pkgs; };
  my.theme = {
		base16 = base16.mkSchemeAttrs colour;

	  font.package = pkgs.source-code-pro;
	  font.name = "Source Code Pro";
	  font.size = 9;
	};
in
{
  picom-ibhagwan = pkgs.picom.overrideAttrs(o: { src = inputs.picom-ibhagwan; });
  
  zsh-vi-mode = pkgs.callPackage ./zsh-vi-mode.nix { src = inputs.zsh-vi-mode; };
  
	lf = pkgs.callPackage ./lf.nix { inherit pkgs my; };
	mpv = pkgs.callPackage ./mpv.nix { inherit pkgs my; };
	imv = pkgs.callPackage ./imv.nix { inherit pkgs my; };
	git = pkgs.callPackage ./git.nix { inherit pkgs my; };
	btop = pkgs.callPackage ./btop.nix { inherit pkgs my; };
  kitty = pkgs.callPackage ./kitty.nix { inherit pkgs my; };
  helix = pkgs.callPackage ./helix.nix { inherit pkgs my; };
	direnv = pkgs.callPackage  ./direnv.nix { inherit pkgs my; };
	zathura = pkgs.callPackage ./zathura.nix { inherit pkgs my; };
  qutebrowser = pkgs.callPackage ./qutebrowser.nix { inherit pkgs my; };
	
	firefox = pkgs.callPackage ./firefox.nix { inherit pkgs my; };
}
