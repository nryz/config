{ pkgs, lib }:

with lib;
rec {
    
  collectMachines = dir:
    let
        mapMachines = dir:
          mapAttrs' (n: v: 
            nameValuePair n (dir + "/${n}")
          ) ((filterAttrs (n: v: v == "directory"))(builtins.readDir dir));
    in mapMachines dir;
}
