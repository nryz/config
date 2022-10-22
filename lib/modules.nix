{ pkgs, lib }:

with lib;
rec {
  collectModules = dir:
    let
      mapModules = dir:
        mapAttrsToList (n: v: v) (mapAttrs' (n: v: 
          if v == "directory" then 
              if hasAttrByPath ["default.nix"] (builtins.readDir (dir + "/${n}")) then 
                nameValuePair n (dir + "/${n}/default.nix")
              else nameValuePair n (mapModules (dir + "/${n}"))
          else nameValuePair (removeSuffix ".nix" n) ( (dir + "/${n}"))
        ) (builtins.readDir dir));
    in  flatten (mapModules dir);
}
