args: let
  pkgs = args.packages.pkgs;
  configPath = args.configPath;

  listChanges = ''
    prev="$(find "/nix/var/nix/profiles" -name "system-*-link" | sort -V | tail --lines=2 | head -1)"
    new="$(find "/nix/var/nix/profiles" -name "system-*-link" | sort -V | tail -1)"

    ${pkgs.nvd}/bin/nvd diff ''${prev} ''${new}
  '';


  apps = {
    install = ''
      echo "TODO"
      
      #format and stuff
      
      #build the system
      #nix --extra-experimental-features nix-command --extra-experimental-features flakes build .#nixosConfigurations.''${$1}.config.system.build.toplevel
      
      #install the system
      #mkdir /mnt/mnt
      #mount --bind /mnt /mnt/mnt
      #nixos-install --system ./result --no-root-passwd
    '';
    
    update = ''
      if [ -z "$1" ]; then
        echo "updating all inputs"
        nix flake update ${configPath}
      else
        echo "updating ''${1} input"
        nix flake lock ${configPath} --update-input $1
      fi
    '';
    switch = ''
      case $1 in
      "build")
        echo "nixos-rebuild build"
        pushd ${configPath} > /dev/null
        sudo nixos-rebuild build --flake ${configPath}
        if [ $? -eq 0 ]; then
          prev="$(find "/nix/var/nix/profiles" -name "system-*-link" | sort -V | tail --lines=2 | head -1)"
          new="./result"

          ${pkgs.nvd}/bin/nvd diff ''${prev} ''${new}
        fi
        popd > /dev/null
      ;;
      
      "boot")
        echo "nixos-rebuild boot"
        sudo nixos-rebuild boot --flake ${configPath}      
      ;;

      *)
        echo "nixos-rebuild switch"
        sudo nixos-rebuild switch --flake ${configPath}
        if [ $? -eq 0 ]; then
          ${listChanges}
        fi
      esac
    '';

    clean = ''
      sudo nix-collect-garbage -d
      sudo nix-store --optimise
    '';
    rollback = ''sudo nixos-rebuild switch --flake ${configPath} --rollback'';

    list-generations = ''sudo nix-env --list-generations --profile /nix/var/nix/profiles/system'';
    list-installed = ''${pkgs.nvd}/bin/nvd list'';
    list-changes = ''${listChanges}'';
    list-gcroots = ''
      sudo -i nix-store --gc --print-roots | egrep -v '^(/nix/var|/run/current-system|/run/booted-system|/proc|{memory|{censored)'
      find -H /nix/var/nix/gcroots/auto -type l | xargs -I {} sh -c 'readlink {}; realpath {}; echo'
    '';

    find-file = ''nix-locate "$1"'';
    find-pkg = ''nix search nixpkgs "''${@:1}"'';
    find-drv = ''nix edit -f "<nixpkgs>" $1'';
  };
in {${args.system} = builtins.mapAttrs (name: value: {
    type = "app";
    program = "${pkgs.writeShellScriptBin "${name}" ''${value}''}/bin/${name}";
}) apps;}
