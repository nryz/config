{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.persist = with types; {
    directories = mkOpt (listOf str) [];
    files = mkOpt (listOf str) [];
  };

  config = {
    programs.fuse.userAllowOther = true;

    environment.persistence."${config.persist.path}/system" = {
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager"
        "/etc/ssh"
        "/etc/nixos"
      ] ++ config.persist.directories;

      files = [
        "/etc/machine-id"
      ] ++ config.persist.files;

    };

    environment.persistence."${config.persist.path}" = {
      users = mapAttrs (n: v: {
        files = [] ++ v.persist.files;
	directories = [
         "Downloads"
         "Music"
         "Pictures"
         "Documents"
         "Videos"
         "Projects"
         "Config"
         ".ssh"
         ".gnupg"
         ".cache/nix-index"
         ".local/Trash"
         ".local/nix"
 	] ++ v.persist.directories;
      }) config.home-manager.users;
    };
  };
}
