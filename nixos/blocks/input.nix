{ config, lib, pkgs, info, packages, ... }: 

with lib;
with lib.my;
let
  cfg = config.blocks.input;
  
  pkg = packages.xremap;
  
  configFile = pkgs.writeTextFile {
    name = "xremap-config.yml";
    text = pkgs.lib.generators.toYAML {} cfg.config;
  };
in
{
  options.blocks.input = with types; {
    enable = mkOpt bool false;
    
    config = mkOpt attrs {};
  };

  config = mkIf cfg.enable {
    blocks.input.config = {
      keymap = [{
        name = "global";
        remap = {
          "Super-z" = {
            launch = ["${pkgs.rofi}/bin/rofi"];
          };
        };
      }];
    };
  
  
    environment.systemPackages = with packages; [ pkg ];
    
    users.groups.uinput.members = [ info.user ];
    users.groups.input.members = [ info.user ];
    
    hardware.uinput.enable = true;
    
    systemd.user.services.xremap = {
      enable = false;
      description = "xremap hotkey daeom";
      path = [ pkg ];

      wantedBy = [ "graphical-session.target" ];

      serviceConfig = {
        KeyringMode = "private";
        SystemCallArchitectures = [ "native" ];
        RestrictRealtime = true;
        LockPersonality = true;
        UMask = "077";
        SystemCallFilter = map (x: "~@${x}") [ 
          "clock" "debug" "module" 
          "reboot" "swap" "cpu-emulation" 
          "obsolete" "privileged" "resources" 
        ];
        RestrictAddressFamilies = "AF_UNIX";

        ExecStart = ''
          ${pkg}/bin/xremap ${configFile}
        '';
      };
    };
  };
}
