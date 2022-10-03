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
    
    packages = {
      url = "path:./packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    base16 = { url = "github:SenchoPens/base16.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    base16-qutebrowser = { url = "github:theova/base16-qutebrowser"; flake = false; };
    base16-zathura = { url = "github:haozeke/base16-zathura"; flake = false; };

    zsh-pure-prompt = { url = "github:sindresorhus/pure"; flake = false; };
  };

  outputs = inputs @ { self, utils, ... }: let args = rec {
    inherit inputs;
    system = "x86_64-linux";
    user = "nr";
    configPath = "/home/${user}/config";

    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;

      overlays = [
        inputs.nur.overlay
        inputs.utils.overlay
      ];
    };

    packages = inputs.packages.packages.${system};
  
    base16 = {
      qutebrowser = inputs.base16-qutebrowser;
      zathura = inputs.base16-zathura;
    };
  };
  in {

    nixosConfigurations = import ./nixos args;
    
    templates = import ./templates;

  } // utils.lib.eachDefaultSystem (system: {

    apps = inputs.packages.apps.${system} // { 
      default = import ./nixos/st args; 
    };

    packages = inputs.packages.packages.${system} // {
    };

  });
}
