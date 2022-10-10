{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.my.persist;
  
  stateCfg = config.my.state;
in
{

  options.my = with types; {
    persist.enable = mkOpt bool false;
    persist.path = mkOpt' str;
    
    state = {
      directories = mkOpt (listOf str) [];
      files = mkOpt (listOf str) [];

      user.directories = mkOpt (listOf str) [];
      user.files = mkOpt (listOf str) [];
    };
    
    backup = {
      directories = mkOpt (listOf str) [];
      files = mkOpt (listOf str) [];

      user.directories = mkOpt (listOf str) [];
      user.files = mkOpt (listOf str) [];
    };
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
      ] ++ stateCfg.directories;

      files = [
        "/etc/machine-id"
      ] ++ stateCfg.files;

    };

    environment.persistence."${cfg.path}" = {
      hideMounts = true;
      users = mapAttrs (n: v: {
        files = map (f: { file = f; parentDirectory = { user = n; group = "users"; }; }) 
          stateCfg.user.files;

        directories = [
          "downloads"
          "music"
          "pictures"
          "documents"
          "videos"
          "projects"
          "config"
        ] ++ map (f: { directory = f; user = n; group = "users"; }) 
          stateCfg.user.directories;
      }) config.home-manager.users;
    };
  };
}
