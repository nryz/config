{ config, lib, ... }: let

  post-mount-script = ''
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
  '';

in {
  fileSystems."/nix".neededForBoot = true;

  disko = {
    devices.disk.main = {
      name = "nixos";
      device = "/dev/disk/by-id/ata-Crucial_CT525MX300SSD1_164614AEBEA4";
      type = "disk";
      postMountHook = post-mount-script;
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "boot";
            start = "1M";
            end = "512M";
            bootable = true;
            content.type = "filesystem";
            content.format = "vfat";
            content.mountpoint = "/boot";
          }
          {
            name = "nix";
            start = "512M";
            end = "-16GB";
            part-type = "primary";
            content.type = "filesystem";
            content.format = "ext4";
            content.mountpoint = "/nix";
          }
          {
            name = "swap";
            start = "-16GB";
            end = "100%";
            part-type = "primary";
            content.type = "swap";
            content.randomEncryption = true;
          }
        ];
      };
    };

    devices.nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [ "defaults" "size=3G" "mode=755" ];
      };
    };
  };
}
