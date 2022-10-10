{ inputs, pkgs, lib, my } : let
  
  machines = my.lib.collectMachines ./machines;
  blocks = my.lib.collectBlocks ./blocks;

in lib.mapAttrs (name: machineFolder: let

  specialArgs = {
    inherit inputs pkgs lib;
    
    my = my // {
      flakePath = ../.;
      hostName = name;
    };
  };

in lib.nixosSystem {
  inherit pkgs specialArgs;
  system = pkgs.system;

  modules = blocks ++ [
    (machineFolder + "/hardware.nix")
    (machineFolder + "/config.nix")
    inputs.utils.nixosModules.autoGenFromInputs
    inputs.base16.nixosModule
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
  ];
}) machines
