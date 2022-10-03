{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    
    swhkd = { url = "github:waycrate/swhkd"; flake = false; };
    zsh-vi-mode = { url = "github:jeffreytse/zsh-vi-mode"; flake = false; };

    picom-ibhagwan = { url = "github:ibhagwan/picom"; flake = false; };
    
    xremap = { url = "github:k0kubun/xremap"; flake = false; };
  };

  outputs = inputs @ { self, nixpkgs, utils, naersk, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        
        packages = {
          swhkd = naersk-lib.buildPackage { name = "swhkd"; src = inputs.swhkd; };
          
          xremap = naersk-lib.buildPackage { name = "xremap"; src = inputs.xremap; };

          picom-ibhagwan = pkgs.picom.overrideAttrs(o: { src = inputs.picom-ibhagwan; });
          
          zsh-vi-mode = pkgs.callPackage ./zsh-vi-mode.nix { src = inputs.zsh-vi-mode; };
        };
        
        apps = {
        };
      });
}