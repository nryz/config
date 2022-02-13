{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.scripts;
in
{
  options.blocks.scripts = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nvd
      (pkgs.writeScriptBin "system" (''
        #!/usr/bin/env bash
        configPath=~/config
      '' + (builtins.readFile ./system-tool.sh)))
      (pkgs.writeScriptBin "why-depends" (builtins.readFile ./why-depends.sh))
    ];
  };
}
