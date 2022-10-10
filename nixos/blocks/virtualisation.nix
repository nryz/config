{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.blocks.virtualisation;
in
{
  options.blocks.virtualisation = with types; {
    enable = mkOpt bool false;
    users = with types; mkOpt (listOf str) [];
  };

  config = mkIf cfg.enable {
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
