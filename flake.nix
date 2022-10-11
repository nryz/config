{
  description = "NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    impermanence.url = "github:nix-community/impermanence";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.utils.follows = "utils";
    
    zsh-pure-prompt.url = "github:sindresorhus/pure"; 
    zsh-pure-prompt.flake = false;
    
    zsh-vi-mode.url = "github:jeffreytse/zsh-vi-mode"; 
    zsh-vi-mode.flake = false;
    
    picom-ibhagwan.url = "github:ibhagwan/picom";
    picom-ibhagwan.flake = false;

    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";

    base16.url = "github:SenchoPens/base16.nix"; 
    base16.inputs.nixpkgs.follows = "nixpkgs";

    naersk.url = "github:nix-community/naersk/master";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, utils, ... }: let 
    user = "nr";
    colour = ./content/base16/solarized-dark.yaml;
  in {

    nixosConfigurations = import ./nixos { inherit self inputs user colour; };
    
    templates = import ./templates;

  } // utils.lib.eachDefaultSystem (system: {

    apps.default = import ./nixos/st { inherit system inputs user; }; 

    packages = import ./packages { inherit system inputs colour; };
  });
}
