{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.scripts;

  fzfSeedbox = pkgs.writeShellScriptBin "fzfSeedbox" ''
    #!/usr/bin/env bash

    stty -echo
    trap 'stty echo' EXIT

    secretsFolder="''${HOME}/.secrets"

    if test -f "''${secretsFolder}/seedbox"; then
      readarray -t lines < "''${secretsFolder}/seedbox"
      server="''${lines[0]}"
      user="''${lines[1]}"
      password="''${lines[2]}"
    else
      server="''$(passage show root/servers/seedbox/url)"
      user="''$(passage show root/servers/seedbox/username)"
      password="''$(passage show root/servers/seedbox/password)"

      mkdir ''${secretsFolder}

      printf '%s\n' $server $user $password > "''${secretsFolder}/seedbox"
    fi


    ret="$(ncftpls -1 -x "R" -i "*" ftp://$user:$password@$server/files/ | grep ".\.mkv" | sort | fzf)"

    if [ -n "$ret" ]; then
      readarray -t paths <<<"$ret"
      for p in "''${paths[@]}"
      do
        umpv "sftp://$user:$password@$server/files/$p" &
        sleep .5
        echo "''${p}" >> "''${secretsFolder}/history"
      done
    fi

    stty echo
    trap - EXIT
  '';
in
{
  options.blocks.scripts = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    blocks.persist.files = [ ".secrets/history"];

    home.packages = with pkgs; [
      fzfSeedbox

      skim
      sysz
    ];
  };
}
