{ config, lib, libs, pkgs, ... }:

with lib;
with libs.flake;
let
  cfg = config.blocks.boot;
in
{
  options.blocks.boot = with types; {
    enable = mkOpt bool true;
  };

  config = mkIf cfg.enable {
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;

      kernelParams = [ 
        "quiet"
        "splash"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
        "vt.global_cursor_default=0"
        #"plymouth:debug"
      ];
      consoleLogLevel = 0;
      initrd.verbose = false;
      plymouth.enable = true;
      plymouth.theme = "text";

      loader =  {
        timeout = 1;
        systemd-boot = {
          enable = true;
          configurationLimit = 20;
          consoleMode = "auto";
          editor = false;
        };
        efi.canTouchEfiVariables = true;
      };
    };
  };
}
