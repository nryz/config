{ pkgs, lib }:

with lib;
rec {
  collectHosts = dir:
    let
        mapHosts = dir:
          mapAttrs' (n: v: 
            nameValuePair n (dir + "/${n}")
          ) ((filterAttrs (n: v: v == "directory"))(builtins.readDir dir));
    in mapHosts dir;

  collectModules = dir:
    let
      mapModules = dir:
       mapAttrs' (n: v: 
          if v == "directory" then 
              if hasAttrByPath ["default.nix"] (builtins.readDir (dir + "/${n}")) then 
                nameValuePair n (dir + "/${n}/default.nix")
              else nameValuePair n (mapModules (dir + "/${n}"))
          else nameValuePair (removeSuffix ".nix" n) ( (dir + "/${n}"))
        ) (builtins.readDir dir);
    in mapModules dir;

  collectModulesToList = dir:
    let
      mapModules = dir:
        mapAttrsToList (n: v: v) (mapAttrs' (n: v: 
          if v == "directory" then 
              if hasAttrByPath ["default.nix"] (builtins.readDir (dir + "/${n}")) then 
                nameValuePair n (dir + "/${n}/default.nix")
              else nameValuePair n (mapModules (dir + "/${n}"))
          else nameValuePair (removeSuffix ".nix" n) ( (dir + "/${n}"))
        ) (builtins.readDir dir));
    in flatten (mapModules dir);
}
