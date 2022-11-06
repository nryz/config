{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.persist;
  
  cfgHome = config.home;
  
  homeModule = with types; { name, config, ... }:
    {
      options.persist = {
        directories = mkOpt (listOf str) [];
        files = mkOpt (listOf str) [];
      };
    };
in
{

  options = with types; {
    persist.path = mkOpt' str;
    persist.directories = mkOpt (listOf str) [];
    persist.files = mkOpt (listOf str) [];
    
    home = mkOption {
      type = types.attrsOf (types.submodule homeModule);
    };
  };
  
  config = mkIf (cfg.path != "") {
    assertions = [{
        assertion = config.fileSystems."/".fsType == "tmpfs"; 
        message = "no root tmpfs found";
    }];

    programs.fuse.userAllowOther = true;

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
      hideMounts = true;
      users = (mapAttrs (n: v: {
        files = map (f: { file = f; parentDirectory = { user = n; group = "users"; }; }) 
          v.persist.files;

        directories = [
          "Downloads"
          "Media"
          "projects"
          "config"
        ] ++ map (f: { directory = f; user = n; group = "users"; }) 
          v.persist.directories;
      }) cfgHome);
    };
  };
}
