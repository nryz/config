{ config, lib, pkgs, ... }:

{
  persist.directories = [ "/etc/ssh" ];
  persist.userDirectories = [ ".ssh" ];

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
}
