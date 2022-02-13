{ config, options, lib, pkgs, extraPkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.sway-launcher-desktop;
in
{
  options.blocks.programs.sway-launcher-desktop = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (
        pkgs.writeShellScriptBin "sway-launcher-desktop" 
          ''
            TERMINAL_COMMAND=${config.defaults.terminal} HIST_FILE= ${extraPkgs.sway-launcher-desktop}/bin/sway-launcher-desktop "$@"
          ''
      )
     ];

    xdg.configFile."sway-launcher-desktop/providers.conf" = {
      text = ''
        [desktop]
        list_cmd=${extraPkgs.sway-launcher-desktop}/bin/sway-launcher-desktop list-entries
        preview_cmd=${extraPkgs.sway-launcher-desktop}/bin/sway-launcher-desktop describe-desktop "{1}"
        launch_cmd=${extraPkgs.sway-launcher-desktop}/bin/sway-launcher-desktop run-desktop '{1}' {2}

        [command]
        list_cmd=${extraPkgs.sway-launcher-desktop}/bin/sway-launcher-desktop list-commands
        preview_cmd=${extraPkgs.sway-launcher-desktop}/bin/sway-launcher-desktop describe-command "{1}"
        launch_cmd=$TERMINAL_COMMAND {1}
      '';
    };
  };
}
