
{ inputs, pkgs, my
, wrapPackage
, base16
}:

let
  lib = pkgs.lib;
  
in wrapPackage {
  pkg = pkgs.skim;
  name = "sk";

  shell = true;
  
  flags = [
    "--reverse"
    "--height=60%"
    "--preview '${placeholder "out"}/scripts/preview.sh {}'"
    "--bind=ctrl-space:toggle-preview,alt-space:toggle+down,tab:down,btab:up"
    "--preview-window=:hidden"
  ];

  scripts = {
    "scripts/preview.sh" = ''
      #!/usr/bin/env bash

      if [ -z "$1" ]; then
        echo "usage: $0 FILENAME"
        exit 1
      fi

      IFS=':' read -r -a INPUT <<< "$1"
      FILE=''${INPUT[0]}
      
      if [[ -f $FILE ]]; then
        ${pkgs.bat}/bin/bat --style=numbers --color=always $FILE
        exit 0
      fi
      
      if [[ -d $FILE ]]; then
        tree -C $FILE | less
        exit 0
      fi
  '';
 };
}