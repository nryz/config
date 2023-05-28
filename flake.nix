{
  description = "NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-22.11";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    impermanence.url = "github:nix-community/impermanence";

    yt-dlp.url = "github:yt-dlp/yt-dlp";
    yt-dlp.flake = false;
   
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

  outputs = inputs @ { self, utils, ... }: let 
    system = "x86_64-linux";
  	pkgs = import inputs.nixpkgs { 
  		inherit system; 

      config.allowUnfree = true;

      overlays = [  
        (self: super: {
          herbstluftwm = inputs.nixpkgs-stable.legacyPackages.${system}.herbstluftwm;
        })
        inputs.nur.overlay
      ];
  	};

    lib = import ./lib { inherit pkgs; };
  in {
    inherit lib;

    nixosConfigurations = import ./nixos { inherit self pkgs system; };
    nixosModules = lib.collectModules ./nixos/profiles;

    templates = import ./templates;
    packages.${system} = import ./packages { inherit self system pkgs; };

    hosts = import ./scripts/hosts.nix { inherit self system pkgs; };
    flake = import ./scripts/flake-app.nix { inherit self system pkgs; };
  };
}
