{ config, lib, pkgs, ... }:

{
  persist.directories = [ "/etc/ssh" ];

  # environment.systemPackages = with pkgs; [
  #   gnupg
  #   yubikey-personalization
  # ];

  # environment.shellInit = ''
  #   gpg-connect-agent /bye
  #   export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  # '';

  # programs = {
  #   ssh.startAgent = false;

  #   gnupg.agent = {
  #     enable = true;
  #     pinentryFlavor = "curses";
  #   };
  # };

  programs.ssh.startAgent = true;
  services = {
    pcscd.enable = true;
    #yubikey-agent.enable = true;

    openssh = {
      enable = true;
      passwordAuthentication = false;
    };
  };
}
