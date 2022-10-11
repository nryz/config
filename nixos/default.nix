{ self, inputs, user, colour } : let

  system = "x86_64-linux";
  
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;

    overlays = [ 
      inputs.nur.overlay 
    ];
  };

  lib = inputs.nixpkgs.lib;
  
  my = {
    inherit user;
    flakePath = ../.;

    pkgs = self.packages.${system};
    lib = import ../lib { inherit pkgs; };

    libs.hm = inputs.home-manager.lib.hm;
		theme.base16 = (pkgs.callPackage inputs.base16 {}).mkSchemeAttrs colour;
  };
  
  machines = my.lib.collectMachines ./machines;
  blocks = my.lib.collectBlocks ./blocks;

in lib.mapAttrs (name: machineFolder: let

  specialArgs = {
    inherit inputs pkgs lib;
    
    my = my // { hostName = name; };
  };

in lib.nixosSystem {
  inherit system pkgs specialArgs;

  modules = blocks ++ [
    (machineFolder + "/hardware.nix")
    (machineFolder + "/config.nix")
    inputs.utils.nixosModules.autoGenFromInputs
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
  ];
}) machines
