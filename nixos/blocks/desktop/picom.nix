{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.desktop.picom;
in
{
  options.blocks.desktop.picom = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {

    # hm.systemd.user.services.picom = {
    #   Unit = {
    #     Description = "Picom X11 compositor";
    #     After = [ "graphical-session-pre.target" ];
    #     PartOf = [ "graphical-session.target" ];
    #   };

    #   Install = { WantedBy = [ "graphical-session.target" ]; };

    #   Service = {
    #     ExecStart = "${my.pkgs.picom}/bin/picom";
    #     Restart = "always";
    #     RestartSec = 3;
    #   };
    # };

  };
}
