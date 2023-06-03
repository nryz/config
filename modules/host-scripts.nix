{ inputs, ... }: let

in ({ config, options, pkgs, lib, ... }:

let
  cfg = config.host-scripts;
in
{
  options.host-scripts = with lib; {
    type = mkOption {
      type = types.enum [ 
        "desktop"
        "server"
        "isoImage"
        "sdImage"
        null
      ];

      default = null;
    };
  };

  config.system.build.host-scripts = let
   check-flake = ''
      if ! [ -f ./flake.nix ]; then
        echo "No flake.nix in this directory."
        exit 1
      fi
    '';

    check-ISO = ''
      if ! [ -d "/iso" ]; then
        echo "Not running in an ISO image probably"
        exit 1
      fi
    '';

    check-host = ''
      if ! [ $(hostname) == "${config.networking.hostName}" ]; then
        echo "Not running on the correct host"
        exit 1
      fi
    '';

    build = (pkgs.writeShellScriptBin "nixos-build" ''
      ${check-flake}
  
      if nix build ${config.system.build.toplevel}; then
        ${pkgs.nvd}/bin/nvd diff /run/current-system result
      fi
    '');

    activate = (pkgs.writeShellScriptBin "nixos-activate" ''
      ${check-flake}
      ${check-host}

      if [ -f ./result/bin/switch-to-configuration ]; then
        sudo nix-env -p /nix/var/nix/profiles/system --set $(readlink result)
        sudo result/bin/switch-to-configuration switch
      fi
    '');

    switch = (pkgs.writeShellScriptBin "nixos-switch" ''
      ${check-flake}
      ${check-host}

      if sudo nix build ${config.system.build.toplevel}; then
        ${pkgs.nvd}/bin/nvd diff /run/current-system result
        sudo nix-env -p /nix/var/nix/profiles/system --set $(readlink result)
        sudo result/bin/switch-to-configuration switch
      fi
    '');

    diff-hardware-configuration = (pkgs.writeShellScriptBin "nixos-diff-hardware-configuration" ''
      ${check-flake}
      ${check-host}

      ${pkgs.diffutils}/bin/diff --color ./hosts/${config.networking.hostName}/hardware-configuration.nix <(nixos-generate-config --no-filesystems --show-hardware-config 2> /dev/null)
    '');

    format = (pkgs.writeShellScriptBin "nixos-format" ''
      ${check-flake}
      ${check-ISO}

      if [[ $(findmnt -M "/mnt") ]]; then
        sudo umount -R /mnt
        sudo swapoff PARTLABEL=swap
      fi

      nix build ${config.system.build.formatScript}
      sudo ./result

      nix build ${config.system.build.mountScript}
      sudo ./result

    '');

    install = (pkgs.writeShellScriptBin "nixos-install" ''
      ${check-flake}
      ${check-ISO}

      if ! [ -f /mnt/nix/passwords ]; then
        sudo mkdir /mnt/nix/passwords
      fi

      ${lib.concatStrings ( lib.mapAttrsToList (user: userValue: ''
        if ! [ -f /mnt/nix/passwords/${user} ]; then
          echo "Input password for user ${user}"
          mkpasswd -m SHA-512 | sudo tee /mnt/nix/passwords/${user} > /dev/null
        fi
      '') (lib.filterAttrs (n: v: v.isNormalUser) config.users.users))}

      ${lib.concatStrings ( lib.mapAttrsToList (path: pathValue: ''
        if ! [ -d /mnt${path} ]; then
          sudo mkdir /mnt${path}
        fi
      '') config.environment.persistence)}
  
      sudo nixos-install --flake .#${config.networking.hostName} --no-root-passwd
    '');

    rollback = (pkgs.writeShellScriptBin "nixos-rollback" ''
      ${check-flake}
      ${check-host}

      sudo nixos-rebuild switch --flake .#${config.networking.hostName} --rollback
    '');

    clean = (pkgs.writeShellScriptBin "nixos-clean" ''
      sudo nix-collect-garbage -d
      sudo nix-store --optimise
    '');

    show-generations = (pkgs.writeShellScriptBin "nixos-show-generations" ''
      sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
    '');

    show-gc-roots = (pkgs.writeShellScriptBin "nixos-gc-roots" ''
      find -H /nix/var/nix/gcroots/auto -type l | xargs -I {} sh -c 'readlink {}; realpath {}; echo'
    '');

    desktopScripts = {
      inherit build activate switch rollback;
      inherit diff-hardware-configuration;
      inherit format install;
      inherit clean show-generations show-gc-roots;
    };

    serverScripts = {
      inherit build;
      inherit diff-hardware-configuration;
      inherit format install;
      inherit clean show-generations show-gc-roots;

      # activate = activate-remote;
      # switch = switch-remote;
      # rollback = rollback-remote;
    };

    isoImageScripts = {
      build = (pkgs.writeShellScriptBin "iso-build" ''
        ${check-flake}

        nix build ${config.system.build.isoImage}
      '');


      flash = (pkgs.writeShellScriptBin "iso-flash" ''
        ${check-flake}

        if [ -z "$1" ]; then
          echo "the first argument must be the device to flash to."
        else
          if [ -f ./result/iso/${config.isoImage.isoName} ]; then
            sudo ${pkgs.coreutils}/bin/dd if=result/iso/${config.isoImage.isoName} of=$1 bs=1M status=progress
          else
            echo "build iso first"
          fi
        fi
      '');
    } // (lib.mkIf (config.nixpkgs.system == "x86_64-linux") {
      test-vm = (pkgs.writeShellScriptBin "iso-test" ''
        ${check-flake}

        if [ -f ./result/iso/${config.isoImage.isoName} ]; then
          ${pkgs.qemu}/bin/qemu-system-x86_64 -enable-kvm -m 1024 -cdrom result/iso/${config.isoImage.isoName}
        else
          echo "build iso first"
        fi
      '');
    });

    sdImageScripts = {
       build = (pkgs.writeShellScriptBin "sd-image-build" ''
        nix build ${config.system.build.sdImage}
      '');

      flash = (pkgs.writeShellScriptBin "sd-image-flash" ''
        ${check-flake}

        if [ -z "$1" ]; then
          echo "the first argument must be the device to flash to."
        else
          if [ -f ./result/sd-image/${config.sdImage.imageName} ]; then
            sudo ${pkgs.pkgsBuildHost.coreutils}/bin/dd if=result/sd-image/${config.sdImage.imageName} of=$1 bs=1M status=progress
          else
            echo "build image first"
          fi
        fi
      '');
    };
    
  in if cfg.type == "desktop" then desktopScripts
     else if cfg.type == "server" then serverScripts
     else if cfg.type == "iso-image" then  isoImageScripts 
     else if cfg.type == "sd-image" then sdImageScripts
     else {};
}) 
