args: let
  lib = import ../lib { inherit (args) inputs; };
  systemBlocks = lib.my.collectBlocks ../blocks/system;
  homeBlocks = lib.my.collectBlocks ../blocks/home;
  packages = import ./packages.nix { inherit (args) inputs system; };
  flakePath = ../.;

in lib.mapAttrs (name: value: 
let
  systemInfo = {
    scalability = {
      cpu = 1;
      gpu = 1;
      diskSpace = 1;
    };

    hardware = {
      ssd = false;
      nvidia = false;
      amd = false;

      primaryDisplay.name = "";
    };
  } // (import (value.hardware + /settings.nix));
in lib.nixosSystem {
  inherit (packages) pkgs;
  inherit (args) system;

  specialArgs = {
    inherit lib flakePath systemInfo;
    inherit (packages) pkgs extraPkgs;
    inherit (args) inputs;
    blocks = systemBlocks;
  };

  modules = [
    ../blocks/system/base.nix
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
        users = (lib.mapAttrs (n: v: {
          shell = pkgs."${config.home-manager.users.${n}.defaults.shell}";
          extraGroups = [ "wheel" ];
          isNormalUser = true;
          passwordFile = "/etc/passwords/${n}";
        }) value.sudoUsers) // { root.hashedPassword = "!"; };
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "HMBACKUP";

        sharedModules = [
          ../blocks/home/base.nix
          args.inputs.homeage.homeManagerModules.homeage
          args.inputs.base16.homeManagerModule
        ];

        extraSpecialArgs = {
          inherit lib flakePath systemInfo;
          inherit (packages) pkgs extraPkgs;
          inherit (args) inputs;
          blocks = homeBlocks;
        };

        users = lib.mapAttrs (n: v: { 
          home.username = n;
          home.homeDirectory = "/home/${n}";
          home.stateVersion = args.stateVersion;
          programs.home-manager.enable = true;
          imports = [ v ];  
        }) value.sudoUsers;
      };

      assertions = [
        {
          assertion = value.sudoUsers != {};
          message = "no users are setup.";
        }
        {
          assertion = lib.hasAttr "/etc/passwords" config.fileSystems;
          message = "no passwords dir in fileSystems";
        }
      ];
    })
    value.hardware
    value.profile
  ];
}) args.configs
