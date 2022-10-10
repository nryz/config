{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.autologin;

  gettyCfg = config.services.getty;

  baseArgs = [
    "--skip-login" 
  ] ++ optionals (gettyCfg.autologinUser != null) [
    "--login-options" "-f ${gettyCfg.autologinUser}"
  ] ++ gettyCfg.extraArgs;

  gettyCmd = args:
    "@${pkgs.util-linux}/sbin/agetty agetty ${escapeShellArgs baseArgs} ${args}";
in
{
  options.blocks.autologin = with types; {
    enable = mkOpt bool false;

    user = mkOpt str "${my.user}";
  };

  config = mkIf cfg.enable {

    # source file to autostart x/wayland wm
    environment.etc."profile.local".text = ''
      if [ -f "$HOME/.config/.autostart" ]; then
        . $HOME/.config/.autostart
      fi
    '';

    services.getty = {
      autologinUser = cfg.user;
      greetingLine = "";
      helpLine = "";
      extraArgs = [ "--noissue" ];
    };

    systemd.services."getty@".serviceConfig.ExecStart = mkForce [
      ""
      (gettyCmd "--noclear --keep-baud %I $TERM")
    ];
  };
}
