{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
{
  options.persist = with types; {
    directories = mkOpt (listOf str) [];
    files = mkOpt (listOf str) [];
  };
}
