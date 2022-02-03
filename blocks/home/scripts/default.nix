{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  fzfSeedbox = pkgs.writeShellScriptBin "fzfSeedbox" ''
    #!/usr/bin/env bash

    stty -echo
    trap 'stty echo' EXIT

    server="''$(passage show root/servers/seedbox/url)"
    user="''$(passage show root/servers/seedbox/username)"
    password="''$(passage show root/servers/seedbox/password)"

    ret="$(ncftpls -1 -x "R" -i "*" ftp://$user:$password@$server/files/ | grep ".\.mkv" | sort | fzf)"

    if [ -n "$ret" ]; then
      readarray -t paths <<<"$ret"
      for p in "''${paths[@]}"
      do
        umpv "sftp://$user:$password@$server/files/$p" &
        sleep .5
      done
    fi

    stty echo
    trap - EXIT
  '';
in
{
  home.packages = with pkgs; [
    fzfSeedbox

    skim
    sysz
  ];
}
