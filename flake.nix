{
  description = "NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    impermanence.url = "github:nix-community/impermanence";
   
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
    
    joshuto.url = "github:kamiyaa/joshuto";
    joshuto.flake = false;
    
    nix-index-database.url = "github:Mic92/nix-index-database";
  };

  outputs = inputs @ { self, utils, ... }: {
    inherit self;

    nixosConfigurations = import ./nixos { inherit self; };
    
    templates = import ./templates;

  } // utils.lib.eachDefaultSystem (system: {

    apps.default = import ./nixos/st { inherit system inputs; }; 

    packages = import ./packages { inherit self system; };
  });
}
