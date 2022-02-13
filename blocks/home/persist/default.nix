{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.persist;
in
{
  options.blocks.persist = with types; {
    enable = mkOpt bool false;
    directories = mkOpt (listOf str) [];
    files = mkOpt (listOf str) [];
  };

  config = mkIf cfg.enable {
    blocks.persist.directories = [
      "downloads"
      "music"
      "pictures"
      "documents"
      "videos"
      "projects"
      "config"
    ];
  };
}
