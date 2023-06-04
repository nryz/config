{lib}:
with lib; rec {
  collectConfigurationDirs = dir: let
    mapDir = dir:
      mapAttrs' (
        n: v:
          nameValuePair n (dir + "/${n}")
      ) ((filterAttrs (n: v: v == "directory")) (builtins.readDir dir));
  in
    mapDir dir;

  collectConfigurations = dir: let
    mapDir = dir:
      mapAttrs' (
        n: v:
          if v == "directory"
          then nameValuePair n (dir + "/${n}/configuration.nix")
          else nameValuePair (removeSuffix ".nix" n) (dir + "/${n}")
      ) (filterAttrs (
        n: v: (v
          == "directory"
          && hasAttrByPath ["configuration.nix"] (builtins.readDir (dir + "/${n}"))
          || (v == "regular"))
      ) (builtins.readDir dir));
  in
    mapDir dir;

  collectModules = dir: let
    mapModules = dir:
      mapAttrs' (
        n: v:
          if v == "directory"
          then
            if hasAttrByPath ["default.nix"] (builtins.readDir (dir + "/${n}"))
            then nameValuePair n (dir + "/${n}/default.nix")
            else nameValuePair n (mapModules (dir + "/${n}"))
          else nameValuePair (removeSuffix ".nix" n) (dir + "/${n}")
      ) (builtins.readDir dir);
  in
    mapModules dir;

  collectModulesToList = dir: let
    mapModules = dir:
      mapAttrsToList (n: v: v) (mapAttrs' (
        n: v:
          if v == "directory"
          then
            if hasAttrByPath ["default.nix"] (builtins.readDir (dir + "/${n}"))
            then nameValuePair n (dir + "/${n}/default.nix")
            else nameValuePair n (mapModules (dir + "/${n}"))
          else nameValuePair (removeSuffix ".nix" n) (dir + "/${n}")
      ) (builtins.readDir dir));
  in
    flatten (mapModules dir);
}
