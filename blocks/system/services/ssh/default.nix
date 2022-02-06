{ config, lib, pkgs, ... }:

{
  persist.directories = [ "/etc/ssh" ];

  # programs.ssh = {
  #   startAgent = true;
  #   askPassword = "${pkgs.ssh-askpass-fullscreen}/bin/ssh-askpass-fullscreen";
  # };

  services = {
    pcscd.enable = true;

    openssh = {
      enable = true;
      logLevel = "VERBOSE";
      #startWhenNeeded = true;
      passwordAuthentication = false;
    };
  };
}
