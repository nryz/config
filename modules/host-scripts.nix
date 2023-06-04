{inputs, ...}: let
in ({
  config,
  options,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host-scripts;

  mkScript = name: script: (pkgs.writeShellScriptBin name script);
in {
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

    backup = mkOption {
      type = types.listOf types.string;
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

    build = mkScript "build-script" ''
      ${check-flake}

      if nix build ${config.system.build.toplevel}; then
        if [ $(hostname) == "${config.networking.hostName}" ]; then
          ${pkgs.nvd}/bin/nvd diff /run/current-system result
        fi
      fi
    '';

    activate = mkScript "activate-script" ''
      ${check-flake}
      ${check-host}

      if [ -f ./result/bin/switch-to-configuration ]; then
        sudo nix-env -p /nix/var/nix/profiles/system --set $(readlink result)
        sudo result/bin/switch-to-configuration switch
      fi
    '';

    switch = mkScript "switch-script" ''
      ${check-flake}
      ${check-host}

      if sudo nix build ${config.system.build.toplevel}; then
        ${pkgs.nvd}/bin/nvd diff /run/current-system result
        sudo nix-env -p /nix/var/nix/profiles/system --set $(readlink result)
        sudo result/bin/switch-to-configuration switch
      fi
    '';

    diff-hardware-configuration = mkScript "diff-hardware-configuration-script" ''
      ${check-flake}
      ${check-host}

      ${pkgs.diffutils}/bin/diff --color ./hosts/${config.networking.hostName}/hardware-configuration.nix <(nixos-generate-config --no-filesystems --show-hardware-config 2> /dev/null)
    '';

    format = mkScript "format-script" ''
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

    '';

    install = mkScript "install-script" ''
      ${check-flake}
      ${check-ISO}


      sudo nixos-install --flake .#${config.networking.hostName} --no-root-passwd
    '';

    rollback = mkScript "rollback-script" ''
      ${check-flake}
      ${check-host}

      sudo nixos-rebuild switch --flake .#${config.networking.hostName} --rollback
    '';

    clean = mkScript "clean-script" ''
      sudo nix-collect-garbage -d
      sudo nix-store --optimise
    '';

    show-generations = mkScript "nixos-show-generations-script" ''
      sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
    '';

    show-gc-roots = mkScript "nixos-gc-roots-script" ''
      find -H /nix/var/nix/gcroots/auto -type l | xargs -I {} sh -c 'readlink {}; realpath {}; echo'
    '';

    backup =
      if (cfg ? backup)
      then
        (mkScript "backup-script" ''
          ${check-host}

          if [ -z "$1" ]; then
            echo "the first argument must be the device to backup to."
            exit 1;
          fi

          sudo mkdir /tmp/backup

          if sudo mount $1 /tmp/backup; then

            DEST=/tmp/backup/$(date +"%Y-%m-%d")
            sudo mkdir $DEST

            ${lib.concatStrings (builtins.map (x: ''
              sudo ${pkgs.rsync}/bin/rsync -ahr --progress ${x} $DEST
            '')
            cfg.backup)}

            sudo umount /tmp/backup
          fi

          sudo rmdir /tmp/backup

        '')
      else {};

    desktopScripts = {
      inherit build activate switch rollback;
      inherit diff-hardware-configuration;
      inherit format install;
      inherit clean show-generations show-gc-roots;
      inherit backup;
    };

    serverScripts = {
      inherit build;

      switch = mkScript "switch-script" ''
        set -e

        ${check-flake}

        outpath=${config.system.build.toplevel.outPath}
        hostname=${config.networking.hostName}

        if [ "$1" ]; then
          hostname=$1
        fi

        if sudo nix build ${config.system.build.toplevel}; then

          echo "Copying system closure to target"
          nix-copy-closure --to $hostname $outpath

          echo "Activating system closure on target"
          ssh -t $hostname sudo nix-env -p /nix/var/nix/profiles/system --set $outpath
          ssh -t $hostname sudo $outpath/bin/switch-to-configuration switch
        fi
      '';
    };

    isoImageScripts =
      {
        build = mkScript "build-script" ''
          ${check-flake}

          nix build ${config.system.build.isoImage}
        '';

        flash = mkScript "flash-script" ''
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
        '';
      }
      // (
        if (config.nixpkgs.system == "x86_64-linux")
        then {
          test-vm = mkScript "test-script" ''
            ${check-flake}

            if [ -f ./result/iso/${config.isoImage.isoName} ]; then
              ${pkgs.qemu}/bin/qemu-system-x86_64 -enable-kvm -m 1024 -cdrom result/iso/${config.isoImage.isoName}
            else
              echo "build iso first"
            fi
          '';
        }
        else {}
      );

    sdImageScripts = {
      build = mkScript "build-script" ''
        nix build ${config.system.build.sdImage}
      '';

      flash = mkScript "flash-script" ''
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
      '';
    };
  in
    if cfg.type == "desktop"
    then desktopScripts
    else if cfg.type == "server"
    then serverScripts
    else if cfg.type == "isoImage"
    then isoImageScripts
    else if cfg.type == "sdImage"
    then sdImageScripts
    else {};
})
