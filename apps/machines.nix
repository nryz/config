{ self, system, pkgs } :
let
  lib = self.inputs.nixpkgs.lib;
in lib.mapAttrs' (n: v: lib.nameValuePair n (let
  build-script = ''
    if sudo nixos-rebuild build --flake .#${n}; then
      ${pkgs.nvd}/bin/nvd diff /run/current-system result
    fi
  '';

  activate-script = ''
    sudo result/bin/switch-to-configuration switch
  '';

  in {
    build =  (pkgs.writeShellScriptBin "nixos-build" ''
      ${build-script}
    '');

    activate =  (pkgs.writeShellScriptBin "nixos-activate" ''
      ${activate-script}
    '');

    activate-dry =  (pkgs.writeShellScriptBin "nixos-activate-dry" ''
      sudo result/bin/switch-to-configuration dry-activate
    '');

    activate-test =  (pkgs.writeShellScriptBin "nixos-activate-test" ''
      sudo result/bin/switch-to-configuration test
    '');
   
    switch = (pkgs.writeShellScriptBin "nixos-switch" ''
      ${build-script}
      ${activate-script}
    '');

    rollback = (pkgs.writeShellScriptBin "nixos-rollback" ''
      sudo nixos-rebuild switch --flake .#${n} --rollback
    '');

    clean = (pkgs.writeShellScriptBin "nixos-clean" ''
      sudo nix-collect-garbage -d
      sudo nix-store --optimise
    '');

    show-generations = (pkgs.writeShellScriptBin "nixos-show-generations" ''
      sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
    '');
})) self.nixosConfigurations
