{ self, pkgs, system } : let

  inputs = self.inputs;

  lib = inputs.nixpkgs.lib;
  
  my = {
    pkgs = self.packages.${system};
    lib = self.lib;
  };
  
  hosts = my.lib.collectHosts ./hosts;

in (lib.mapAttrs (name: hostFolder: let

  specialArgs = {
    inherit inputs pkgs lib;

    profiles = self.nixosModules;
    
    my = my // { hostName = name; };
  };

in lib.nixosSystem {
  inherit system pkgs specialArgs;

  modules = [
    (hostFolder + "/hardware-configuration.nix")
    (hostFolder + "/disk-configuration.nix")
    (hostFolder + "/configuration.nix")
    inputs.utils.nixosModules.autoGenFromInputs
    inputs.disko.nixosModules.disko
  ];
}) hosts) //
{
  iso = lib.nixosSystem {
    inherit system;
    modules = [
      (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
      ({ pkgs, lib, ...}:
      {
        isoImage.storeContents = [ ] ++ (lib.mapAttrsToList (n: v:
          v.config.system.build.toplevel
        ) (lib.filterAttrs (n: v: !(v.config.system.build ? isoImage)) self.nixosConfigurations));
      
        isoImage.contents = [ {
          source = self.outPath;
          target = "config";
        } ];

        nix.package = pkgs.nixUnstable;
        nix.extraOptions = ''
          experimental-features = nix-command flakes
        '';

        boot.postBootCommands = ''
          mkdir /home/nixos/config
          cp -r /iso/config/* /home/nixos/config/
          chown -R nixos:users /home/nixos/config
          chmod -R +w /home/nixos/config
        '';

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
