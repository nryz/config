{ config, lib, pkgs, ... }:

{
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;

  networking.nameservers = [
    "2a07:a8c0::df:f735"
    "2a07:a8c1::df:f735"
  ];

  networking.networkmanager = {
    enable = true;
  };

  programs.nm-applet = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    networkmanager
    sshfsFuse
    lftp
    ncftp
    inetutils
  ];
}
