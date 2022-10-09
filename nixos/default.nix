input : let
  inherit (input) info pkgs libs inputs packages theme;

  lib = libs.lib;
  
  machines = libs.flake.collectMachines ./machines;
  blocks = libs.flake.collectBlocks ./blocks;

in lib.mapAttrs (name: machineFolder: let

  specialArgs = {
    inherit pkgs packages libs;
    inherit theme lib inputs;
    
    info = {
      user = info.user;
      stateVersion = "21.11";
      flakePath = ../.;
      hostName = name;
    };
  };
in lib.nixosSystem {
  inherit (info) system;
  inherit pkgs specialArgs;

  modules = blocks ++ [
    (machineFolder + "/hardware.nix")
    (machineFolder + "/config.nix")
    inputs.utils.nixosModules.autoGenFromInputs
    inputs.base16.nixosModule
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
  ];
}) machines
