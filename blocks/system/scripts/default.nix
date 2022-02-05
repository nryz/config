{ config, lib, pkgs, ... }:

with lib;
with lib.my;
{
  environment.systemPackages = with pkgs; [
    nvd
    (pkgs.writeScriptBin "system" (''
      #!/usr/bin/env bash
      configPath=~/Config
    '' + (builtins.readFile ./system-tool.sh)))
    (pkgs.writeScriptBin "why-depends" (builtins.readFile ./why-depends.sh))
  ];
}

