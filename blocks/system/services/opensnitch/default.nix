{ config, lib, pkgs, ... }:

{
  persist.directories = [ "/var/lib/opensnitch" ];
  services.opensnitch.enable = true;
}
