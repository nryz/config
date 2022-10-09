{ inputs, pkgs, libs, theme }:

let
	lib = pkgs.lib;
in
{
  picom-ibhagwan = pkgs.picom.overrideAttrs(o: { src = inputs.picom-ibhagwan; });
  
  zsh-vi-mode = pkgs.callPackage ./zsh-vi-mode.nix { src = inputs.zsh-vi-mode; };
  
  helix = pkgs.callPackage ./helix.nix { inherit pkgs libs theme; };
  qutebrowser = pkgs.callPackage ./qutebrowser.nix { inherit pkgs libs theme; };
  kitty = pkgs.callPackage ./kitty.nix { inherit pkgs libs theme; };
	mpv = pkgs.callPackage ./mpv.nix { inherit pkgs libs theme; };
	lf = pkgs.callPackage ./lf.nix { inherit pkgs libs theme; };
}
