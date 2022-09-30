{ config, lib, pkgs, extraPkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.xremap;
in
{
  options.blocks.xremap = with types; {
    enable = mkOpt bool true;
  };

  config = let
    usersAttr = filterAttrs (n: v: v.blocks.desktop.xremap.enable ) config.home-manager.users;
    users = mapAttrsToList (n: v: n) usersAttr;
    
    enabled = usersAttr != {};
  in  mkIf (enabled && cfg.enable) {

    environment.systemPackages = [
      extraPkgs.xremap
    ];

    hardware.uinput.enable = true;

    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", TAG+="uaccess"
    '';
        
      users.groups.uinput.members = users;
      users.groups.input.members = users;
      
  };
}
