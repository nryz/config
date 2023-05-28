{ self, system, pkgs } :
let
  lib = self.inputs.nixpkgs.lib;
in lib.mapAttrs' (host: hostValue: if hostValue.config.system.build ? isoImage then lib.nameValuePair host (let
in {
    build = (pkgs.writeShellScriptBin "iso-build" ''
      nix build .#nixosConfigurations.${host}.config.system.build.isoImage
    '');

    test-vm = (pkgs.writeShellScriptBin "iso-test" ''
      if [ -f ./result/iso/${hostValue.config.isoImage.isoName} ]; then
        ${pkgs.qemu}/bin/qemu-system-x86_64 -enable-kvm -m 1024 -cdrom result/iso/${hostValue.config.isoImage.isoName}
      else
        echo "build iso first"
      fi
    '');

    dd = (pkgs.writeShellScriptBin "iso-dd" ''
      if [ -z "$1" ]; then
        echo "the first argument must be the device to flash to."
      else
        if [ -f ./result/iso/${hostValue.config.isoImage.isoName} ]; then
          sudo ${pkgs.coreutils}/bin/dd if=result/iso/${hostValue.config.isoImage.isoName} of=$1 bs=1M status=progress
        else
          echo "build iso first"
        fi
      fi
    '');

}) else lib.nameValuePair host (let
    check-flake = ''
      if ! [ -f ./flake.nix ]; then
        echo "No flake.nix is this directory."
        exit 1
      fi
    '';

    check-ISO = ''
      if ! [ -d "/iso" ]; then
        echo "Not running in an ISO image probably"
        exit 1
      fi
    '';

  in {
    build =  (pkgs.writeShellScriptBin "nixos-build" ''
      ${check-flake}
      
      if nix build .#nixosConfigurations.${host}.config.system.build.toplevel; then
        ${pkgs.nvd}/bin/nvd diff /run/current-system result
      fi
    '');

    activate =  (pkgs.writeShellScriptBin "nixos-activate" ''
      ${check-flake}

      if [ -f ./result/bin/switch-to-configuration ]; then
        sudo nix-env -p /nix/var/nix/profiles/system --set $(readlink result)
        sudo result/bin/switch-to-configuration switch
      fi
    '');
   
    switch = (pkgs.writeShellScriptBin "nixos-switch" ''
      ${check-flake}

      if sudo nix build .#nixosConfigurations.${host}.config.system.build.toplevel; then
        ${pkgs.nvd}/bin/nvd diff /run/current-system result
        sudo nix-env -p /nix/var/nix/profiles/system --set $(readlink result)
        sudo result/bin/switch-to-configuration switch
      fi
    '');

    rollback = (pkgs.writeShellScriptBin "nixos-rollback" ''
      ${check-flake}

      sudo nixos-rebuild switch --flake .#${host} --rollback
    '');

    clean = (pkgs.writeShellScriptBin "nixos-clean" ''
      sudo nix-collect-garbage -d
      sudo nix-store --optimise
    '');

    show-generations = (pkgs.writeShellScriptBin "nixos-show-generations" ''
      sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
    '');

    diff-hardware-configuration = (pkgs.writeShellScriptBin "nixos-diff-hardware-configuration" ''
      ${pkgs.diffutils}/bin/diff --color ./nixos/hosts/${host}/hardware-configuration.nix <(nixos-generate-config --no-filesystems --show-hardware-config 2> /dev/null)
    '');


    format = (pkgs.writeShellScriptBin "nixos-format" ''
      ${check-ISO}

      if [[ $(findmnt -M "/mnt") ]]; then
        sudo umount -R /mnt
        sudo swapoff PARTLABEL=swap
      fi

      nix build .#nixosConfigurations.${host}.config.system.build.formatScript
      sudo ./result

      nix build .#nixosConfigurations.${host}.config.system.build.mountScript
      sudo ./result

    '');

    install = (pkgs.writeShellScriptBin "nixos-install" ''
      ${check-ISO}

      if ! [ -f /mnt/nix/passwords ]; then
        sudo mkdir /mnt/nix/passwords
      fi

      ${lib.concatStrings ( lib.mapAttrsToList (user: userValue: ''
        if ! [ -f /mnt/nix/passwords/${user} ]; then
          echo "Input password for user ${user}"
          mkpasswd -m SHA-512 | sudo tee /mnt/nix/passwords/${user} > /dev/null
        fi
      '') (lib.filterAttrs (n: v: v.isNormalUser) self.nixosConfigurations.${host}.config.users.users))}

      ${lib.concatStrings ( lib.mapAttrsToList (path: pathValue: ''
        if ! [ -d /mnt${path} ]; then
          sudo mkdir /mnt${path}
        fi
      '') self.nixosConfigurations.${host}.config.environment.persistence)}
      
      sudo nixos-install --flake .#${host} --no-root-passwd
    '');


    
    })) self.nixosConfigurations
