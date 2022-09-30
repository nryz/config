{ config, lib, pkgs, extraPkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.desktop.xremap;
in
{
  options.blocks.desktop.xremap = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {

    xdg.configFile."xremap/config.yml".text = ''
      keymap:
        - name: test
          remap:
            SUPER-space: 
              launch: ["rofi -show drun"]
            SUPER-KEY_g: 
              launch: ["rofi -show window"]
    '';
    

    # systemd.user.services.xremap = {
    #   Install.WantedBy = [ "graphical-session.target" ];
    #   Service = {
    #     ExecStart = '' ${extraPkgs.xremap}/bin/xremap ~/.config/xremap/config.yml '';
    #     Restart = "always";
    #     RestartSec = 3;
    #   };
    #   Unit = {
    #     Description = "xremap user service";
    #     After = [ "graphical-session-pre.target" ];
    #     PartOf = [ "graphical-session.target" ];
    #   };
    # };
  };
}
