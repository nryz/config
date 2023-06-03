{ nixosModules, self, config, options, pkgs, lib, ... }:
let
  stateVersion = "21.11";
in
{
  imports = [
    nixosModules.nix-inputs
    nixosModules.disko
    nixosModules.mypkgs
    nixosModules.host-scripts
  ];

  config = {
    time.hardwareClockInLocalTime = true;

    system.stateVersion = stateVersion;

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    nixpkgs.config.allowUnfree = true;

    users.mutableUsers = false;

    users.users.nr = {
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      passwordFile = "/nix/passwords/nr";
      uid = 1000;

      openssh.authorizedKeys.keys = [
        ''sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBDNTt4bRrULwwSunmzEfMe17TsdEO5erbKCiEGBZh8HcimgVOwtFo+bGqcJGHJA76B3rB/AI3nBDC90M8+k/PP0AAAAEc3NoOg==''
      ];
    };

    users.users.root.hashedPassword = "!";

    services.resolved.enable = true;

    nix.package = pkgs.nixUnstable;

    nix.extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
      allow-dirty = true
      keep-outputs = true
      keep-derivations = true

      max-free = ${toString (10 * 1024 * 1024 * 1024)}
      min-free = ${toString (2 * 1024 * 1024 * 1024)}
    '';

    nix.gc.automatic = true;
    nix.gc.options = "--delete-older-than 30d";
    nix.gc.dates = "weekly";
    nix.settings.auto-optimise-store = true;
  };
}
