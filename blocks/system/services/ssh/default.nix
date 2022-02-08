{ config, lib, pkgs, ... }:

{
  persist.directories = [ "/etc/ssh" ];
  persist.userDirectories = [ ".ssh" ];

  programs.ssh = {
    startAgent = true;
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
