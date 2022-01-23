{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  fzfSeedbox = pkgs.writeShellScriptBin "fzfSeedbox" ''
    #!/usr/bin/env bash

    stty -echo
    trap 'stty echo' EXIT

    server="''$(passage show server/seedbox/url)"
    user="''$(passage show server/seedbox/username)"
    password="''$(passage show server/seedbox/password)"

    path="$(ncftpls -1 -x "-d */*.mkv" ftp://$user:$password@$server/files/ | fzf)"

    if [ -n "$path" ]; then
      mpv "sftp://$user:$password@$server/files/$path"
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
