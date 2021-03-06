pushd $configPath > /dev/null

listChanges() {
  prev="$(find "/nix/var/nix/profiles" -name "system-*-link" | sort -V | tail --lines=2 | head -1)"
  new="$(find "/nix/var/nix/profiles" -name "system-*-link" | sort -V | tail -1)"

  nvd diff ${prev} ${new}
}

case $1 in
"update")
  if [ -z "$2" ]; then
    nix flake update
  else
    nix flake lock --update-input $2
  fi
;;

"switch")
  sudo nixos-rebuild switch --flake .# ${@:2}
  if [ $? -eq 0 ]; then
    listChanges
  fi
;;

"build")
  sudo nixos-rebuild build --flake .# ${@:2}

  if [ $? -eq 0 ]; then
    prev="$(find "/nix/var/nix/profiles" -name "system-*-link" | sort -V | tail --lines=2 | head -1)"
    new="./result"

    nvd diff ${prev} ${new}
  fi
;;

"boot")
  sudo nixos-rebuild boot --flake .# ${@:2}
;;

"dry")
  sudo nixos-rebuild dry-activate --flake .# ${@:2}
;;

"clean")
  sudo nix-collect-garbage -d
  sudo nix-store --optimise
;;

"rollback")
  sudo nixos-rebuild switch --flake .# --rollback
;;

"generations")
  sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
;;

"installed")
  nvd list
;;

"changes")
  listChanges
;;

"gcroots")
  sudo -i nix-store --gc --print-roots | egrep -v '^(/nix/var|/run/current-system|/run/booted-system|/proc|{memory|{censored)'
  find -H /nix/var/nix/gcroots/auto -type l | xargs -I {} sh -c 'readlink {}; realpath {}; echo'
;;

"locate")
  nix-locate --whole-name --type x --type s --no-group --type x --type s --top-level --at-root "/bin/$3"
;;

"search")
  nix search nixpkgs "${@:2}"
;;

"addBlock")
  if [ $2 = "home" ]; then
    mkdir "blocks/home/$3"
tee -a "blocks/home/$3/default.nix" <<EOF
{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.
in
{
  options.blocks. = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
  };
}
EOF

  elif [ $2 = "system" ]; then
    mkdir "blocks/system/$3"
tee -a "blocks/system/$3/default.nix" <<EOF
{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.
in
{
  options.blocks. = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
  };
}
EOF
  fi
;;

"find-drv")
  nix edit -f "<nixpkgs>" $2
;;

"list-units")
  sudo journalctl --field _SYSTEMD_UNIT
;;

"errors")
  sudo journalctl -p 3 -xb
;;

"status")
  if [ $2 = "user" ]; then
    systemctl status --user $3
  else
    sudo systemctl status $2
  fi
;;

"unitErrors")
  if [ $2 = "user" ]; then
    journalctl --user -p 3 -xb -u $3
  else
    sudo journalctl -p 3 -xb -u $2
  fi
;;

"log")
  if [ $2 = "user" ]; then
    journalctl --user -e -u $3
  else
    sudo journalctl -e -u $2
  fi
;;

*)
  echo "system update       - update flake inputs"
  echo "system switch       - nixos-rebuild switch"
  echo "system build        - nixos-rebuild build"
  echo "system boot         - nixos-rebuild boot"
  echo ""
  echo "system clean        - garbage collect"
  echo ""
  echo "system generations  - list generations"
  echo "system installed    - list installed packages"
  echo "system gcroots      - list gcroots"
  echo "system changes      - list changes"
  echo ""
  echo "system locate       - locate package in the /nix/store"
  echo "system search       - find package"
  echo "system edit-drv     - open a drv in the /nix/store"
esac

popd > /dev/null
