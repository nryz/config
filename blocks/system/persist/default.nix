{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.persist;
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.blocks.persist = with types; {
    enable = mkOpt bool false;
    directories = mkOpt (listOf str) [];
    userDirectories = mkOpt (listOf str) [];
    files = mkOpt (listOf str) [];
    userFiles = mkOpt (listOf str) [];
    path = mkOpt' str;
  };

  config = mkIf cfg.enable {
    assertions = [{
        assertion = config.fileSystems."/".fsType == "tmpfs"; 
        message = "no root tmpfs found";
    }];

    programs.fuse.userAllowOther = true;

    environment.systemPackages = with pkgs; [
      ncdu
    ];

    environment.persistence."${cfg.path}/system" = {
      hideMounts = true;

      directories = [
        "/var/log"
        "/var/lib/systemd/coredump"
        "/var/db/sudo/lectured"
      ] ++ cfg.directories;

      files = [
        "/etc/machine-id"
      ] ++ cfg.files;

    };

    environment.persistence."${cfg.path}" = {
      users = mapAttrs (n: v: {
        files = map (f: { file = f; parentDirectory = { user = n; group = "users"; }; }) 
          (v.blocks.persist.files ++ cfg.userFiles);
        directories = map (f: { directory = f; user = n; group = "users"; }) 
          (v.blocks.persist.directories ++ cfg.userDirectories);
      }) config.home-manager.users;
    };
  };
}
