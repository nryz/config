args: let
  lib = import ../lib { inherit (args) inputs; };
  machines = lib.my.collectMachines ./machines;
  blocks = lib.my.collectBlocks ./blocks;

in lib.mapAttrs (name: machineFolder: let

  info = {
    inherit (args) user configPath;
    stateVersion = "21.11";
    flakePath = ../.;
    hostName = name;
  };
  
  extraModules = {
    kmonad = args.inputs.kmonad.nixosModules.default;
    impermanence = args.inputs.impermanence.nixosModules.impermanence;
  };

  specialArgs = {
    inputs = args.inputs;
    inherit lib info extraModules;
    inherit (args) pkgs packages base16;
  };
in lib.nixosSystem {
  inherit (args) system pkgs;
  inherit specialArgs;

  modules = blocks ++ [
    (machineFolder + "/hardware.nix")
    (machineFolder + "/config.nix")
    args.inputs.utils.nixosModules.autoGenFromInputs
    args.inputs.base16.nixosModule
    args.inputs.home-manager.nixosModules.home-manager 
  ];
}) machines
