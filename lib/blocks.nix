{ lib }:

with lib;
rec {
  # Recursively read dir to collect the paths of modules
  # A valid module is a dir with a default.nix inside
  # Dirs that are a valid modules will not be read further
  collectBlocks = dir:
    let
      mapBlocks = dir:
        mapAttrs' (n: v: 
          if v == "directory" 
              then if hasAttrByPath ["default.nix"] (builtins.readDir (dir + "/${n}"))
              then nameValuePair n (dir + "/${n}/default.nix")
              else nameValuePair n (mapBlocks (dir + "/${n}"))
          else nameValuePair (removeSuffix ".nix" n) ( (dir + "/${n}"))
        ) (filterAttrs (n: v: v == "directory" ) (builtins.readDir dir));
    in  mapBlocks dir;

  collectBlocksToList = dir:
    let
      mapBlocks = dir:
        mapAttrsToList (n: v: v) (mapAttrs' (n: v: 
          if v == "directory" 
              then if hasAttrByPath ["default.nix"] (builtins.readDir (dir + "/${n}"))
              then nameValuePair n (dir + "/${n}/default.nix")
              else nameValuePair n (mapBlocks (dir + "/${n}"))
          else nameValuePair (removeSuffix ".nix" n) ( (dir + "/${n}"))
        ) (filterAttrs (n: v: v == "directory" ) (builtins.readDir dir)));
    in  flatten (mapBlocks dir);
}
