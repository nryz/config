{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    
    zsh-vi-mode = { url = "github:jeffreytse/zsh-vi-mode"; flake = false; };
    picom-ibhagwan = { url = "github:ibhagwan/picom"; flake = false; };
    base16 = { url = "github:SenchoPens/base16.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs @ { self, nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        myLib = import ./lib.nix { inherit pkgs; };

        naersk-lib = pkgs.callPackage inputs.naersk { };
        base16-lib = pkgs.callPackage inputs.base16 {};

        theme.base16 = base16-lib.mkSchemeAttrs ../content/base16/dracula.yaml;
        theme.font = {
          package = pkgs.source-code-pro;
          name = "Source Code Pro";
          size = 9;
        };
      in
      {
        
        packages = {

          picom-ibhagwan = pkgs.picom.overrideAttrs(o: { src = inputs.picom-ibhagwan; });
          
          zsh-vi-mode = pkgs.callPackage ./zsh-vi-mode.nix { src = inputs.zsh-vi-mode; };
          
          helix = pkgs.callPackage ./helix.nix { inherit pkgs myLib theme; };
          qutebrowser = pkgs.callPackage ./qutebrowser.nix { inherit pkgs myLib theme; };
          kitty = pkgs.callPackage ./kitty.nix { inherit pkgs myLib theme; };
        };
        
        apps = {
        };
      });
}