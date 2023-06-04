{
  description = "NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-22.11";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";
    impermanence.url = "github:nix-community/impermanence";

    yt-dlp.url = "github:yt-dlp/yt-dlp";
    yt-dlp.flake = false;

    zsh-pure-prompt.url = "github:sindresorhus/pure";
    zsh-pure-prompt.flake = false;

    zsh-vi-mode.url = "github:jeffreytse/zsh-vi-mode";
    zsh-vi-mode.flake = false;

    picom-ibhagwan.url = "github:ibhagwan/picom";
    picom-ibhagwan.flake = false;

    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";

    base16.url = "github:SenchoPens/base16.nix";
    base16.inputs.nixpkgs.follows = "nixpkgs";

    naersk.url = "github:nix-community/naersk/master";
    naersk.inputs.nixpkgs.follows = "nixpkgs";

    joshuto.url = "github:kamiyaa/joshuto";
    joshuto.flake = false;

    nix-index-database.url = "github:Mic92/nix-index-database";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    lib = import ./lib {lib = nixpkgs.lib;};

    nixosModules =
      (lib.collectModules ./profiles)
      // (nixpkgs.lib.mapAttrs (n: v: import v {inherit inputs;})
        (lib.collectModules ./modules));

    modules =
      nixosModules
      // {
        impermanence = inputs.impermanence.nixosModules.impermanence;
        disko = inputs.disko.nixosModules.disko;
      };

    packages = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
    ] (system: import ./packages {inherit inputs system;});

    devShells = nixpkgs.lib.genAttrs [
      "x86_64-linux"
    ] (system: import ./devshells {inherit inputs system;});

    templates = import ./templates;

    host-scripts =
      nixpkgs.lib.mapAttrs (
        n: v:
          v.config.system.build.host-scripts
      )
      self.nixosConfigurations;

    nixosConfigurations = let
      mkNixosConfiguration = args:
        nixpkgs.lib.nixosSystem (nixpkgs.lib.recursiveUpdate {
            specialArgs = {nixosModules = modules;};
          }
          args);
    in {
      abyss = mkNixosConfiguration {
        system = "x86_64-linux";
        modules = [./hosts/abyss/configuration.nix];
      };

      telas = mkNixosConfiguration {
        system = "aarch64-linux";
        modules = [./hosts/telas/configuration.nix];
      };

      iso-x86_64-linux = mkNixosConfiguration {
        system = "x86_64-linux";
        modules = [./installers/iso-x86_64-linux.nix];

        specialArgs = {
          inherit (self) outPath;
          additionalStorePaths = [
            self.nixosConfigurations.abyss.config.system.build.toplevel
          ];
        };
      };

      sd-rpi4 = mkNixosConfiguration {
        system = "aarch64-linux";
        modules = [./installers/sd-rpi4.nix];

        specialArgs = {
          inherit (self) outPath;
          additionalStorePaths = [
            self.nixosConfigurations.telas.config.system.build.toplevel
          ];
        };
      };
    };
  in {
    inherit lib templates packages devShells;
    inherit nixosConfigurations nixosModules;

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    hosts = host-scripts;
  };
}
