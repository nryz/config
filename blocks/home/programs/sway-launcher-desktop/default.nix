{ config, options, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (
      pkgs.writeShellScriptBin "sway-launcher-desktop" 
        ''
          TERMINAL_COMMAND=${config.defaults.terminal} HIST_FILE= ${sway-launcher-desktop}/bin/sway-launcher-desktop "$@"
        ''
    )
   ];

  xdg.configFile."sway-launcher-desktop/providers.conf" = {
    text = ''
      [desktop]
      list_cmd=${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop list-entries
      preview_cmd=${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop describe-desktop "{1}"
      launch_cmd=${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop run-desktop '{1}' {2}

      [command]
      list_cmd=${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop list-commands
      preview_cmd=${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop describe-command "{1}"
      launch_cmd=$TERMINAL_COMMAND {1}
    '';
  };
}
