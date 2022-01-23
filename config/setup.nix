args: ({ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  sharedModules = [
    ../blocks {
      sourcePath = ../.;
      configPath = "~/Config";
    }
  ];
in
{
  options = with types; {
    home.users = mkOption {
      type = with types; attrsOf (submodule {
        options = {
          shell = (mkOpt' package);
          extraGroups = mkOpt' (listOf str);
          config = mkOpt' anything;
        };
      });
    };
  };

   imports = sharedModules ++ [
      inputs.home-manager.nixosModules.home-manager
      inputs.utils.nixosModules.autoGenFromInputs
      inputs.base16.nixosModule
      args.systemBlocks.core
      args.systemBlocks.persist
      args.systemBlocks.scripts
     (import (args.path + "/${args.hostName}/hardware"))
     (import (args.path + "/${args.hostName}")) 
   ];

  config = {
    system.stateVersion = args.stateVersion;
    networking.hostName = args.hostName;

    #don't know why I have to do this
    nixpkgs.config = args.pkgs.config;
    nixpkgs.pkgs = args.pkgs;

    nix.generateRegistryFromInputs = true;
    nix.generateNixPathFromInputs = true;
    nix.linkInputs = true;

    users.defaultUserShell = pkgs.zsh;
    
    users.mutableUsers = false;
    users.users = mapAttrs (n: v: {
      shell = v.shell;
      extraGroups = v.extraGroups;
      isNormalUser = true;
      passwordFile = "/etc/passwords/${n}";
    }) config.home.users;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "HMBACKUP";

      sharedModules = sharedModules ++ [
        args.homeBlocks.core
        args.homeBlocks.persist
        args.homeBlocks.scripts
        inputs.homeage.homeManagerModules.homeage
        inputs.base16.homeManagerModule
      ];

      extraSpecialArgs = {
        inherit lib inputs;
        blocks = args.homeBlocks;
        pkgs = args.pkgs;
      };

      users = mapAttrs (n: v: { 
        home.username = n;
        home.homeDirectory = "/home/${n}";
        home.stateVersion = args.stateVersion;
        programs.home-manager.enable = true;
        imports = [ v.config ];  
      }) config.home.users;
    };

    assertions = [ 
      {
        assertion = config.home.users != {};
        message = "no users are setup.";
      }
    ];
  };
})
