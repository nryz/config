{ pkgs ? import <nixpkgs> {}, hostName, userName}:

pkgs.mkShell {

  buildInputs = with pkgs; [ 
    nixUnstable
    (pkgs.writeShellScriptBin "setupSystem" ''
      #! /usr/bin/env bash
      ./config/hosts/${hostName}/setup.sh ${userName}
    '')
    (pkgs.writeShellScriptBin "buildSystem" ''
      #! /usr/bin/env bash
      nix --extra-experimental-features nix-command --extra-experimental-features flakes build .#nixosConfigurations.${hostName}.config.system.build.toplevel
    '')
    (pkgs.writeShellScriptBin "installSystem" ''
      #! /usr/bin/env bash
      mkdir /mnt/mnt
      mount --bind /mnt /mnt/mnt
      nixos-install --system ./result --no-root-passwd
    '')
   ];
}
