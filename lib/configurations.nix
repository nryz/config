{ lib, inputs }:

with lib;
with lib.my;
rec {
  mapNixos = dir: fn:
      mapAttrs' ( n: v: nameValuePair n (fn dir n) )
        (filterAttrs (n: v: v == "directory") (builtins.readDir dir));

  mkNixos = path: name: args:
      lib.nixosSystem {
        pkgs = args.pkgs;
        system = args.system;
        specialArgs = { 
          inherit lib inputs; 
          blocks = args.systemBlocks;
          pkgs = args.pkgs;
        };
        modules = [(import ../config/setup.nix {
          inherit (args) pkgs stateVersion systemBlocks homeBlocks;
          inherit path;
          hostName = name;
        })];
      };

  mkNixoses = dir: args:
    mapNixos dir (path: name: mkNixos path name args);
    
    
  collectMachines = dir:
    let
        mapMachines = dir:
          mapAttrs' (n: v: 
            nameValuePair n (dir + "/${n}")
          ) ((filterAttrs (n: v: v == "directory"))(builtins.readDir dir));
    in mapMachines dir;
}
