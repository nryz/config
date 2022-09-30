{
  description = "NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";

    nur.url = "github:nix-community/NUR";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = { url = "github:nix-community/impermanence"; };
    
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    base16 = { url = "github:SenchoPens/base16.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    base16-qutebrowser = { url = "github:theova/base16-qutebrowser"; flake = false; };
    base16-zathura = { url = "github:haozeke/base16-zathura"; flake = false; };
    base16-dunst = { url = "github:khamer/base16-dunst"; flake = false; };

    zsh-pure-prompt = { url = "github:sindresorhus/pure"; flake = false; };
    zsh-vi-mode = { url = "github:jeffreytse/zsh-vi-mode"; flake = false; };

    picom-ibhagwan = { url = "github:ibhagwan/picom"; flake = false; };
    sway-launcher-desktop = { url = "github:Biont/sway-launcher-desktop"; flake = false; };
  };

  outputs = inputs @ { self, ... }: let
    stateVersion = "21.11";
    system = "x86_64-linux";
    defaultUserName = "nr";
    configPath = "/home/${defaultUserName}/config";

    packages = import ./setup/packages.nix { 
      inherit inputs system; 
    };
  in {
    nixosConfigurations = import ./setup/nixos.nix {
      inherit inputs self system packages;
      inherit stateVersion defaultUserName configPath;
    };
    
    apps = import ./setup/apps.nix { 
      inherit system packages configPath; 
    };
    
  };
}
