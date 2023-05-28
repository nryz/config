{ config, ... }: {
    # fileSystems = {
    #   "/" = { 
    #     device = "none";
    #     fsType = "tmpfs";
    #     options = [ "defaults" "size=3G" "mode=755" ];
    #   };
    
    #   "/etc/passwords" = { 
    #     device = "/nix/persist/system/etc/passwords";
    #     fsType = "none";
    #     options = [ "bind" ];
    #     neededForBoot = true;
    #   };
  
    #   "/boot" = { 
    #     device = "/dev/disk/by-uuid/B35B-71DB";
    #     fsType = "vfat";
    #   };
  
    #   "/nix" = { 
    #     device = "/dev/disk/by-uuid/16b17eae-c8a9-48e1-bff2-466c327308b1";
    #     fsType = "ext4";
    #     neededForBoot = true;
    #   };
    # };

  persist.path = "/nix/persist";

  fileSystems."/nix".neededForBoot = true;
  # fileSystems."/etc/passwords".neededForBoot = true;

  disko = {
    devices.disk.main = {
      name = "nixos";
      device = "/dev/sda";
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
        mountOptions = [ "defaults" "size=3G" "mod=755" ];
      };
    };
  };
}
