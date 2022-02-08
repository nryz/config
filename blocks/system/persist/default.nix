{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  config = {
    assertions = [{
        assertion = config.fileSystems."/".fsType == "tmpfs"; 
        message = "no root tmpfs found";
    }];

    programs.fuse.userAllowOther = true;

    environment.systemPackages = with pkgs; [
      ncdu
    ];

    environment.persistence."${config.persist.path}/system" = {
      directories = [
        "/var/log"
        "/var/lib/systemd/coredump"
        "/var/db/sudo/lectured"
      ] ++ config.persist.directories;

      files = [
        "/etc/machine-id"
      ] ++ config.persist.files;

    };

    environment.persistence."${config.persist.path}" = {
      users = mapAttrs (n: v: {
        files = map (f: { file = f; parentDirectory = { user = n; group = "users"; }; }) 
          (v.persist.files ++ config.persist.userFiles);
        directories = map (f: { directory = f; user = n; group = "users"; }) 
          (v.persist.directories ++ config.persist.userDirectories);
      }) config.home-manager.users;
    };
  };
}
