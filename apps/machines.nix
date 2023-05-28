{ self, system, pkgs } :
let
  lib = self.inputs.nixpkgs.lib;
in lib.mapAttrs' (n: v: if v.config.system.build ? isoImage then lib.nameValuePair n (let
in {
    build = (pkgs.writeShellScriptBin "iso-build" ''
      nix build .#nixosConfigurations.${n}.config.system.build.isoImage
    '');

    test-vm = (pkgs.writeShellScriptBin "iso-test" ''
      if [ -f ./result/iso/${v.config.isoImage.isoName} ]; then
        ${pkgs.qemu}/bin/qemu-system-x86_64 -enable-kvm -m 1024 -cdrom result/iso/${v.config.isoImage.isoName}
      else
        echo "build iso first"
      fi
    '');

    dd = (pkgs.writeShellScriptBin "iso-dd" ''
      if [ -z "$1" ]; then
        echo "the first argument must be the device to flash to."
      else
        if [ -f ./result/iso/${v.config.isoImage.isoName} ]; then
          sudo ${pkgs.coreutils}/bin/dd if=result/iso/${v.config.isoImage.isoName} of=$1 bs=1M status=progress
        else
          echo "build iso first"
        fi
      fi
    '');

}) else lib.nameValuePair n (let
    check-flake = ''
      if [ ! -f ./flake.nix ]; then
        echo "No flake.nix is this directory."
        exit 0
      fi
    '';
  in {
    build =  (pkgs.writeShellScriptBin "nixos-build" ''
      ${check-flake}
      
      if nix build .#nixosConfigurations.${n}.config.system.build.toplevel; then
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

      if sudo nix build .#nixosConfigurations.${n}.config.system.build.toplevel; then
        ${pkgs.nvd}/bin/nvd diff /run/current-system result
        sudo nix-env -p /nix/var/nix/profiles/system --set $(readlink result)
        sudo result/bin/switch-to-configuration switch
      fi
    '');

    rollback = (pkgs.writeShellScriptBin "nixos-rollback" ''
      ${check-flake}

      sudo nixos-rebuild switch --flake .#${n} --rollback
    '');

    clean = (pkgs.writeShellScriptBin "nixos-clean" ''
      sudo nix-collect-garbage -d
      sudo nix-store --optimise
    '');

    show-generations = (pkgs.writeShellScriptBin "nixos-show-generations" ''
      sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
    '');

    diff-hardware-configuration = (pkgs.writeShellScriptBin "nixos-diff-hardware-configuration" ''
      ${pkgs.diffutils}/bin/diff --color ./nixos/machines/${n}/hardware-configuration.nix <(nixos-generate-config --no-filesystems --show-hardware-config 2> /dev/null)
    '');

    install = (pkgs.writeShellScriptBin "nixos-install" ''
      if [ -d "/iso" ]; then
        # Format and mount
        # echo nix build .#diskoConfigurations.#{n} ???
        echo nix build .#nixosConfigurations.${n}.config.system.build.diskoScript
        echo ./result
        # Install
        echo mkpasswd -m SHA-512 > /mnt/nix/passwords/nr
        echo nixos-install --flake .#${n} --no-root-passwd
      else
        echo "Not running in an ISO image probably"
      fi
    '');
      # echo mkpasswd -m SHA-512 > /mnt/nix/passwords/nr
      # echo nixos-install --flake .#${n} --no-root-passwd

    
    })) self.nixosConfigurations
