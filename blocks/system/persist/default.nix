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

    environment.systemPackages = with pkgs; [
      ncdu
    ];

    environment.persistence."${config.persist.path}/system" = {
      directories = [
        "/var/log"
        "/var/lib/systemd/coredump"
        "/var/db/sudo/lectured"
        "/etc/nixos"
      ] ++ config.persist.directories;

      files = [
        "/etc/machine-id"
      ] ++ config.persist.files;

    };

    environment.persistence."${config.persist.path}" = {
      users = mapAttrs (n: v: {
        files = map (f: { file = f; parentDirectory = { user = n; group = "users"; }; }) v.persist.files;
        directories = map (f: { directory = f; user = n; group = "users"; }) v.persist.directories;
      }) config.home-manager.users;
    };
  };
}
