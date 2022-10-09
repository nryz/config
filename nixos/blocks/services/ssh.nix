{ config, lib, libs, pkgs, ... }:

with lib;
with libs.flake;
let
  cfg = config.blocks.services.ssh;
in
{
  options.blocks.services.ssh = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.directories = [ "/etc/ssh" ];
    blocks.persist.userDirectories = [ ".ssh" ];

    environment.systemPackages = with pkgs; [
      (pkgs.writeShellScriptBin "ak" ''
        eval $(ssh-agent) >/dev/null
        ssh-add -K
        $@
        eval $(ssh-agent -k) >/dev/null
      '')
    ];

    programs.ssh = {
      startAgent = false;
      askPassword = "${pkgs.ssh-askpass-fullscreen}/bin/ssh-askpass-fullscreen";
    };

    services = {
      pcscd.enable = true;

      openssh = {
        enable = true;
        logLevel = "VERBOSE";
        passwordAuthentication = false;
      };
    };
  };
}
