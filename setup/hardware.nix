{ config, pkgs, lib, ... }: 

with lib;
with lib.my;
let
  systemInfoOptions = with types; {
    scalability = {
      cpu = mkOpt int 1;
      gpu = mkOpt int 1;
      diskSpace = mkOpt int 1;
    };

    hardware = {
      ssd = mkOpt bool false;
      nvidia = mkOpt bool false;
      amd = mkOpt bool false;

      primaryDisplay.name = mkOpt str "";
    };
  };

  cfg = config.systemInfo;

in
{
  options.systemInfo = systemInfoOptions;

  config = {
    home-manager.sharedModules = [
      ({ config, pkgs, lib, ... }: {
        options.systemInfo = systemInfoOptions;
        config = { systemInfo = cfg; };
      })
    ];
  };
}
