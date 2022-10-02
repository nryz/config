args: let
  pkgs = args.pkgs;
  configPath = args.configPath;

  listChanges = ''
    prev="$(find "/nix/var/nix/profiles" -name "system-*-link" | sort -V | tail --lines=2 | head -1)"
    new="$(find "/nix/var/nix/profiles" -name "system-*-link" | sort -V | tail -1)"

    ${pkgs.nvd}/bin/nvd diff ''${prev} ''${new}
  '';
  
  nr = "nixos-rebuild --print-build-logs";


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
      build() {
        echo "${nr} build ''${1}"
        pushd ${configPath} > /dev/null
        sudo ${nr} build --flake ${configPath} ''${1}
        if [ $? -eq 0 ]; then
          prev="$(find "/nix/var/nix/profiles" -name "system-*-link" | sort -V | tail --lines=2 | head -1)"
          new="./result"

          ${pkgs.nvd}/bin/nvd diff ''${prev} ''${new}
        fi
        popd > /dev/null
      }
      
      boot() {
        echo "${nr} boot ''${1}"
        sudo ${nr} boot --flake ${configPath} ''${1}     
      }
      
      switch() {
        echo "${nr} switch ''${1}"
        sudo ${nr} switch --flake ${configPath} ''${1}
        if [ $? -eq 0 ]; then
          ${listChanges}
        fi
      }

      case $1 in
      "debug")
        case $2 in
          "build")
            build "--show-trace"
          ;;
          
          "boot")
            boot "--show-trace"
          ;;
          
          *)
            switch "--show-trace"
          ;;
        esac
      ;;
      
      "build")
        build
      ;;
      
      "boot")
        boot
      ;;


      *)
        switch
      esac
    '';

    clean = ''
      sudo nix-collect-garbage -d
      sudo nix-store --optimise
    '';
    rollback = ''sudo ${nr} switch --flake ${configPath} --rollback'';

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
