args: let
  lib = import ../lib { inherit (args) inputs; };
  systemBlocks = lib.my.collectBlocksToList ../blocks/system;
  homeBlocks = lib.my.collectBlocksToList ../blocks/home;
  packages = args.packages;
  flakePath = ../.;
  
  machines = lib.my.collectMachines ../machines;

  defaultUserName = args.defaultUserName;

  specialArgs = {
    defaultUser = defaultUserName;
    inherit lib flakePath;
    inherit (packages) pkgs extraPkgs pkgsStable;
    inherit (args) inputs configPath;
  };

in lib.mapAttrs (name: machineFolder: lib.nixosSystem {
  inherit (packages) pkgs;
  inherit (args) system;
  inherit specialArgs;

  modules = systemBlocks ++ [
    ../blocks/system/base.nix
    (machineFolder + "/hardware.nix")
    (machineFolder + "/system.nix")
    args.inputs.utils.nixosModules.autoGenFromInputs
    args.inputs.base16.nixosModule
    args.inputs.home-manager.nixosModules.home-manager 
    ({ config, pkgs, ... }: {
      system.stateVersion = args.stateVersion;
      networking.hostName = name;

      nixpkgs.config = packages.pkgs.config;
      nixpkgs.pkgs = packages.pkgs;

      users = {
        mutableUsers = false;
        defaultUserShell = pkgs.zsh;
        
        users.${defaultUserName} = {
          shell = pkgs."${config.home-manager.users.${defaultUserName}.defaults.shell}";
          extraGroups = [ "wheel" ];
          isNormalUser = true;
          passwordFile = "/etc/passwords/${defaultUserName}";
          uid = 1000;
        };

        users.root.hashedPassword = "!";
      };

      home-manager = {
        extraSpecialArgs = specialArgs;

        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "HMBACKUP";

        sharedModules = homeBlocks ++ [
          ../blocks/home/base.nix
          args.inputs.base16.homeManagerModule
        ];

        users.${defaultUserName} = {
          home.username = defaultUserName;
          home.homeDirectory = "/home/${defaultUserName}";
          home.stateVersion = args.stateVersion;
          programs.home-manager.enable = true;
          imports = [ (machineFolder + "/user.nix") ];
        };
      };

      assertions = [
        {
          assertion = lib.hasAttr "/etc/passwords" config.fileSystems;
          message = "no passwords dir in fileSystems";
        }
        {
          assertion = lib.hasAttr "/" config.fileSystems;
          message = "no root in fileSystems";
        }
        {
          assertion = lib.hasAttr "/nix" config.fileSystems;
          message = "no nix in fileSystems";
        }
        {
          assertion = lib.hasAttr "/boot" config.fileSystems;
          message = "no boot in fileSystems";
        }
      ];
    })
  ];
}) machines
