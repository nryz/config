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
        sudo ${pkgs.coreutils}/bin/dd if=result/iso/${v.config.isoImage.isoName} of=/dev/$1 bs=1M status=progress
      fi
    '');

}) else lib.nameValuePair n (let
  build-script = ''
    if sudo nixos-rebuild build --flake .#${n}; then
      ${pkgs.nvd}/bin/nvd diff /run/current-system result
    fi
  '';

  set-profile-script = ''
    sudo nix-env -p /nix/var/nix/profiles/system --set $(readlink result)
  '';

  activate-script = ''
    sudo result/bin/switch-to-configuration switch
  '';

  in {
    build =  (pkgs.writeShellScriptBin "nixos-build" ''
      ${build-script}
    '');

    activate =  (pkgs.writeShellScriptBin "nixos-activate" ''
      ${set-profile-script}
      ${activate-script}
    '');

    activate-dry =  (pkgs.writeShellScriptBin "nixos-activate-dry" ''
      sudo result/bin/switch-to-configuration dry-activate
    '');

    activate-test =  (pkgs.writeShellScriptBin "nixos-activate-test" ''
      ${set-profile-script}
      sudo result/bin/switch-to-configuration test
    '');
   
    switch = (pkgs.writeShellScriptBin "nixos-switch" ''
      ${build-script}
      ${set-profile-script}
      ${activate-script}
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
# })) (lib.filterAttrs (n: v:
#   !(v.config.system.build ? isoImage)
# ) self.nixosConfigurations)
