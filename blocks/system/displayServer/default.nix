{ config, lib, pkgs, defaultUser, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.displayServer;
  defaultUserHome = config.home-manager.users.${defaultUser};
  backend = defaultUserHome.blocks.desktop.displayServer.backend;
in
{
  options.blocks.displayServer = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.wayland.enable = backend == "wayland";
    blocks.xserver.enable = backend == "x";
  };
}
