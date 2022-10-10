{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.network;
in
{
  options.blocks.network = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    my.state.directories = [ "/etc/NetworkManager" ];

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
      sshfs-fuse
      lftp
      ncftp
      inetutils
    ];
  };
}
