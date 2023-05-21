{ self, pkgs } : let

  inputs = self.inputs;

  system = "x86_64-linux";

  lib = inputs.nixpkgs.lib;
  
  my = {
    pkgs = self.packages.${system};
    lib = import ../lib { inherit pkgs; };
  };
  
  machines = my.lib.collectMachines ./machines;
  modules = my.lib.collectModules ./modules;

in (lib.mapAttrs (name: machineFolder: let

  specialArgs = {
    inherit inputs pkgs lib;
    
    my = my // { hostName = name; };
  };

in lib.nixosSystem {
  inherit system pkgs specialArgs;

  modules = modules ++ [
    (machineFolder + "/hardware-configuration.nix")
    (machineFolder + "/configuration.nix")
    inputs.utils.nixosModules.autoGenFromInputs
    inputs.impermanence.nixosModules.impermanence
  ];
}) machines) //
{
  iso = lib.nixosSystem {
    inherit system;
    modules = [
      (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
      ({ pkgs, lib, ...}:
      {
        isoImage.contents = [ {
          source = self.outPath;
          target = "config";
        } ];

        users.users.nixos = {
          shell = my.pkgs.zsh;

          packages = with my.pkgs; [
            joshuto
            helix
          ];
        };
      })
    ];
  };
}
