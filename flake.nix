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
    

    # packages
    zsh-pure-prompt = { url = "github:sindresorhus/pure"; flake = false; };
    zsh-vi-mode = { url = "github:jeffreytse/zsh-vi-mode"; flake = false; };
    picom-ibhagwan = { url = "github:ibhagwan/picom"; flake = false; };

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # config
    base16 = { url = "github:SenchoPens/base16.nix"; inputs.nixpkgs.follows = "nixpkgs"; };

    # builders
    naersk.url = "github:nix-community/naersk/master";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, utils, ... }: let input = rec {
    inherit inputs;
    
    info.system = "x86_64-linux";
    info.user = "nr";

    libs = {
      lib = inputs.nixpkgs.lib;
      flake = import ./lib { inherit pkgs;
      inherit (pkgs) lib; };
      hm = inputs.home-manager.lib.hm;
      naersk = pkgs.callPackage inputs.naersk { };
      base16 = pkgs.callPackage inputs.base16 {};
    };

    theme = {
      base16 = libs.base16.mkSchemeAttrs ./content/base16/dracula.yaml;
      font = {
        package = pkgs.source-code-pro;
        name = "Source Code Pro";
        size = 9;
      };
    };

    pkgs = import inputs.nixpkgs {
      inherit (info) system;
      config.allowUnfree = true;

      overlays = [ 
        inputs.utils.overlay
        inputs.nur.overlay 
      ];
    };
    
    packages = {
      flake = import ./packages {
          inherit inputs pkgs libs theme;
      };
      
      extra = {
        zsh-prompt = inputs.zsh-pure-prompt;
      };
    };
  };
  in {

    nixosConfigurations = import ./nixos input;
    
    templates = import ./templates;

  } // utils.lib.eachDefaultSystem (system: {

    apps.default = import ./nixos/st { inherit (input) pkgs info; }; 

    packages = input.packages.flake;
  });
}
