{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.my;
  
  state.userDirs = filter (x: !(hasPrefix "/" x)) cfg.state.directories;
  state.userFiles = filter (x: !(hasPrefix "/" x)) cfg.state.files;
  state.dirs = filter (x: hasPrefix "/" x) cfg.state.directories;
  state.files = filter (x: hasPrefix "/" x) cfg.state.files;

  backup.userDirs = filter (x: !(hasPrefix "/" x)) cfg.backup.directories;
  backup.userFiles = filter (x: !(hasPrefix "/" x)) cfg.backup.files;
  backup.dirs = filter (x: hasPrefix "/" x) cfg.backup.directories;
  backup.files = filter (x: hasPrefix "/" x) cfg.backup.files;
  
in
{

  options.my = with types; {
    persist.path = mkOpt' str;
    
    persist.users = mkOpt (listOf str) [];
    
    state = {
      directories = mkOpt (listOf str) [];
      files = mkOpt (listOf str) [];
    };
    
    backup = {
      directories = mkOpt (listOf str) [];
      files = mkOpt (listOf str) [];
    };
  };
  
  config = mkIf (cfg.persist.path != "") {
    assertions = [{
        assertion = config.fileSystems."/".fsType == "tmpfs"; 
        message = "no root tmpfs found";
    }];

    programs.fuse.userAllowOther = true;

    environment.persistence."${cfg.persist.path}/system" = {
      hideMounts = true;

      directories = [
        "/var/log"
        "/var/lib/systemd/coredump"
        "/var/db/sudo/lectured"
      ] ++ state.dirs;

      files = [
        "/etc/machine-id"
      ] ++ state.files;

    };

    environment.persistence."${cfg.persist.path}" = {
      hideMounts = true;
      users = listToAttrs (map (n: nameValuePair n {
        files = map (f: { file = f; parentDirectory = { user = n; group = "users"; }; }) 
          state.userFiles;

        directories = [
          "downloads"
          "music"
          "pictures"
          "documents"
          "videos"
          "projects"
          "config"
        ] ++ map (f: { directory = f; user = n; group = "users"; }) 
          state.userDirs;
      }) cfg.persist.users);
    };
  };
}
