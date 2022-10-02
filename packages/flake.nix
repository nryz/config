{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    
    swhkd = { url = "github:waycrate/swhkd"; flake = false; };
    zsh-vi-mode = { url = "github:jeffreytse/zsh-vi-mode"; flake = false; };
    zsh-pure-prompt = { url = "github:sindresorhus/pure"; flake = false; };

    picom-ibhagwan = { url = "github:ibhagwan/picom"; flake = false; };
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

          picom-ibhagwan = pkgs.picom.overrideAttrs(o: { src = inputs.picom-ibhagwan; });
          
          zsh-pure-prompt = {
            name = "pure-prompt";
            src = inputs.zsh-pure-prompt;
            file = "pure.zsh";
          };

          zsh-vi-mode = pkgs.callPackage ./zsh-vi-mode.nix { src = inputs.zsh-vi-mode; };
        };
      });
}