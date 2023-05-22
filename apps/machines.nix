{ self, system, pkgs } :
let
  lib = self.inputs.nixpkgs.lib;
in lib.mapAttrs' (n: v: if v.config.system.build ? isoImage then lib.nameValuePair n (let
in {
    build = (pkgs.writeShellScriptBin "iso-build" ''
      nix build .#nixosConfigurations.${n}.config.system.build.isoImage
    '');

    test = (pkgs.writeShellScriptBin "iso-test" ''
      ${pkgs.qemu}/bin/qemu-system-x86_64 -enable-kvm -m 256 -cdrom result/iso/${v.config.isoImage.isoName}
    '');

    dd = (pkgs.writeShellScriptBin "iso-dd" ''
      if [ -z "$1" ]; then
        echo "the first argument must be the device to flash to."
      else
        sudo ${pkgs.coreutils}/bin/dd if=result/iso/${v.config.isoImage.isoName} of=$1 bs=1M status=progress
      fi
    '');

}) else lib.nameValuePair n (let
  in {
    build =  (pkgs.writeShellScriptBin "nixos-build" ''
      if sudo nix build .#nixosConfigurations.${n}.config.system.build.toplevel; then
        ${pkgs.nvd}/bin/nvd diff /run/current-system result
      fi
    '');

    activate =  (pkgs.writeShellScriptBin "nixos-activate" ''
      sudo nix-env -p /nix/var/nix/profiles/system --set $(readlink result)
      sudo result/bin/switch-to-configuration switch
    '');

    activate-test =  (pkgs.writeShellScriptBin "nixos-activate-test" ''
      sudo nix-env -p /nix/var/nix/profiles/system --set $(readlink result)
      sudo result/bin/switch-to-configuration test
    '');
   
    switch = (pkgs.writeShellScriptBin "nixos-switch" ''
      if sudo nix build .#nixosConfigurations.${n}.config.system.build.toplevel; then
        ${pkgs.nvd}/bin/nvd diff /run/current-system result
        sudo nix-env -p /nix/var/nix/profiles/system --set $(readlink result)
        sudo result/bin/switch-to-configuration switch
      fi
    '');

    rollback = (pkgs.writeShellScriptBin "nixos-rollback" ''
      sudo nixos-rebuild switch --flake .#${n} --rollback
    '');

    clean = (pkgs.writeShellScriptBin "nixos-clean" ''
      sudo nix-collect-garbage -d
      sudo nix-store --optimise
    '');

    show-generations = (pkgs.writeShellScriptBin "nixos-show-generations" ''
      sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
    '');
    })) self.nixosConfigurations
