{ config, lib, pkgs, ... }:

with lib;
with lib.my;
{
  options= with types; {
    system.udevPackages = mkOpt (listOf package) [];
    system.programs = mkOpt (listOf str) [];
  };
}
