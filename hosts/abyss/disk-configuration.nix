{ config, ... }: {
  fileSystems."/nix".neededForBoot = true;

  disko = {
    devices.disk.main = {
      name = "nixos";
      device = "/dev/disk/by-id/ata-Crucial_CT525MX300SSD1_164614AEBEA4";
      type = "disk";
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
