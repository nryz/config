{ lib }:

with lib;
rec {
  collectBlocks = dir:
    let
      mapBlocks = dir:
        mapAttrsToList (n: v: v) (mapAttrs' (n: v: 
          if v == "directory" then 
              if hasAttrByPath ["default.nix"] (builtins.readDir (dir + "/${n}")) then 
                nameValuePair n (dir + "/${n}/default.nix")
              else nameValuePair n (mapBlocks (dir + "/${n}"))
          else nameValuePair (removeSuffix ".nix" n) ( (dir + "/${n}"))
        ) (builtins.readDir dir));
    in  flatten (mapBlocks dir);
}
