{ lib }:

with lib;
rec {
  collectBlocks = path:
    let
      filterEmpty = dir: name:
        (filterAttrs (n: v: 
          (v == "directory" && (filterEmpty (dir + "/${name}") n)) || hasSuffix ".nix" n) 
            (builtins.readDir (dir + "/${name}"))
        ) != {};

      mapBlocks = dir:
        mapAttrs' (n: v: 
          if v == "directory" then
            if hasAttrByPath ["default.nix"] (builtins.readDir (dir + "/${n}")) && (filterEmpty dir n) then
              nameValuePair n (dir + "/${n}/default.nix")
            else
              nameValuePair n (mapBlocks (dir + "/${n}"))
          else 
            nameValuePair (removeSuffix ".nix" n) ( (dir + "/${n}"))
        ) (filterAttrs (n: v: (v == "directory" &&  (filterEmpty dir n)) || hasSuffix ".nix" n) (builtins.readDir dir));
    in  mapBlocks path;
}
