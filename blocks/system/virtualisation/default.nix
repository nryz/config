{ config, lib, pkgs, ... }:

with lib;
with lib.my;
{
  options.virtualisation.users = with types; mkOpt (listOf str) [];

  config = {
    virtualisation = {
      libvirtd.enable = true;
      virtualbox.host.enable = true;
      virtualbox.host.enableExtensionPack = true;
    };

    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [ virt-manager ];

    users.extraGroups.vboxusers.members = [ "user-with-acces-to-virtualbox" ];
    users.users = genAttrs config.virtualisation.users (n: { extraGroups = [ "libvirtd" "vboxusers" ]; } );

  };
}
