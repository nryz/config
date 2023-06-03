{ inputs, ... }: let

in ({ config, options, pkgs, lib, ... }:

{
  nix.registry = builtins.mapAttrs (n: v: {
      flake = v;
    }) (lib.filterAttrs (n: v: v ? outputs) inputs);

  environment.etc = lib.mapAttrs' (n: v: {
      name = "nix/inputs/${n}";
      value.source = v.outPath;
    }) inputs;

  nix.nixPath = [ "/etc/nix/inputs" ];
})
