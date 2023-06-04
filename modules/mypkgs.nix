{inputs, ...}: let
in ({
  config,
  options,
  pkgs,
  lib,
  ...
}: {
  options = {
    mypkgs = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };

    mylib = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };

  config = {
    mypkgs = import ../packages {
      inherit inputs;
      system = config.nixpkgs.system;
    };

    mylib = import ../lib {inherit lib;};
  };
})
