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

  outputs = inputs @ { self, utils, ... }: let 

    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;

      overlays = [ 
        inputs.utils.overlay
        inputs.nur.overlay 
      ];
    };

    lib = inputs.nixpkgs.lib;

    my.user = "nr";
    
    my.libs = {
      hm = inputs.home-manager.lib.hm;
      naersk = pkgs.callPackage inputs.naersk { };
      base16 = pkgs.callPackage inputs.base16 {};
    };

    my.theme = {
      base16 = my.libs.base16.mkSchemeAttrs ./content/base16/dracula.yaml;
      font.package = pkgs.source-code-pro;
      font.name = "Source Code Pro";
      font.size = 9;
    };

    my.pkgs = import ./packages {
        inherit inputs pkgs;
        inherit (my) libs theme;
    };

    my.lib = import ./lib { inherit pkgs; };

  in {

    nixosConfigurations = import ./nixos { inherit inputs pkgs lib my; };
    
    templates = import ./templates;

  } // utils.lib.eachDefaultSystem (system: {

    apps.default = import ./nixos/st { inherit pkgs my; }; 

    packages = my.pkgs;
  });
}
