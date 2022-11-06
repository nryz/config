{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  cfg = config.home;

  fileSubmodule = with types; attrsOf (submodule (
    { name, config, options, ... }:
    { options = {

        enable = mkOption {
          type = types.bool;
          default = true;
        };

        target = mkOption {
          type = types.str;
        };

        text = mkOption {
          default = null;
          type = types.nullOr types.lines;
        };

        source = mkOption {
          type = types.path;
        };

      };

      config = {
        target = mkDefault name;
        source = mkIf (config.text != null) (
          let name' = "etc-" + baseNameOf name;
          in mkDerivedConfig options.text (pkgs.writeText name')
        );
      };

    }));
  
in
{
  options.home = with types; mkOption {
    description = "Users home configuration";
    default = {};

    type = attrsOf (submodule {
      options = {
        packages = mkOption {
          default = [];
          type = listOf package;
        };

        files = mkOption {
          default = null;
          type = fileSubmodule;
        };
        
        shell = mkOption {
          type = shellPackage;
        };
      };
    });
  };

  config = {
    users.users = mapAttrs (n: v: {
      packages = v.packages;
      shell = v.shell;
    } ) cfg;
    
    environment.pathsToLink = mapAttrsToList (n: v: let
      name = v.shell.meta.mainProgram or v.shell.name;
    in "/share/${name}"
    ) cfg;
  };
}
