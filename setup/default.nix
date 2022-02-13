args: let
  lib = import ../lib { inherit (args) inputs; };
  systemBlocks = lib.my.collectBlocksToList ../blocks/system;
  homeBlocks = lib.my.collectBlocksToList ../blocks/home;
  packages = import ./packages.nix { inherit (args) inputs system; };
  flakePath = ../.;

  defaultUserName = "nr";

  specialArgs = {
    defaultUser = defaultUserName;
    inherit lib flakePath;
    inherit (packages) pkgs extraPkgs stablePkgs;
    inherit (args) inputs;
  };

in lib.mapAttrs (name: value: lib.nixosSystem {
  inherit (packages) pkgs;
  inherit (args) system;
  inherit specialArgs;

  modules = systemBlocks ++ [
    ../blocks/system/base.nix
    ./hardware.nix
    value.hardware
    value.profile
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
          args.inputs.homeage.homeManagerModules.homeage
          args.inputs.base16.homeManagerModule
        ];

        users.${defaultUserName} = {
          home.username = defaultUserName;
          home.homeDirectory = "/home/${defaultUserName}";
          home.stateVersion = args.stateVersion;
          programs.home-manager.enable = true;
          imports = [ value.defaultUser ];
        };
      };

      assertions = [
        {
          assertion = lib.hasAttr "/etc/passwords" config.fileSystems;
          message = "no passwords dir in fileSystems";
        }
      ];
    })
  ];
}) args.configs
