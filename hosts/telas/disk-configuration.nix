{ config, ... }: {
  disko = {
    devices.disk.main = {
      name = "nixos";
      device = "/dev/disk/by-id/mmc-Y032V_0xdad6c273";
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "boot";
            start = "1M";
            end = "30M";
            bootable = true;
            content.type = "filesystem";
            content.format = "vfat";
            content.mountpoint = "/boot";
          }
          {
            name = "nix";
            start = "30M";
            end = "-4GB";
            part-type = "primary";
            content.type = "filesystem";
            content.format = "ext4";
            content.mountpoint = "/";
          }
          {
            name = "swap";
            start = "-4GB";
            end = "100%";
            part-type = "primary";
            content.type = "swap";
            content.randomEncryption = true;
          }
        ];
      };
    };
  };
}
