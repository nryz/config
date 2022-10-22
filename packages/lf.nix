{ pkgs, my, wrapPackage, ... }:

let
  lib = pkgs.lib;

  vidthumbFile = pkgs.writeShellScriptBin "vidthumb" ''
    #!/usr/bin/env bash

    if ! [ -f "$1" ]; then
            exit 1
    fi

    cache="$HOME/.cache/vidthumb"
    index="$cache/index.json"
    movie="$(realpath "$1")"

    mkdir -p "$cache"

    if [ -f "$index" ]; then
            thumbnail="$(jq -r ". \"$movie\"" <"$index")"
            if [[ "$thumbnail" != "null" ]]; then
                    if [[ ! -f "$cache/$thumbnail" ]]; then
                            exit 1
                    fi
                    echo "$cache/$thumbnail"
                    exit 0
            fi
    fi

    thumbnail="$(uuidgen).jpg"

    if ! ffmpegthumbnailer -i "$movie" -o "$cache/$thumbnail" -s 0 2>/dev/null; then
            exit 1
    fi

    if [[ ! -f "$index" ]]; then
            echo "{\"$movie\": \"$thumbnail\"}" >"$index"
    fi
    json="$(jq -r --arg "$movie" "$thumbnail" ". + {\"$movie\": \"$thumbnail\"}" <"$index")"
    echo "$json" >"$index"

    echo "$cache/$thumbnail"
  '';
  
  pistolFile = ''
    image/* kitty +kitten icat %s
  '';

  kittyPreviewFile = ''
    #! /usr/bin/env bash
    file=$1
    w=$2
    h=$3
    x=$4
    y=$5

    filetype="$( file -Lb --mime-type "$file")"

    if [[ "$filetype" =~ ^image ]]; then
        kitty +icat --silent --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file"
        exit 1
    fi

    if [[ "$filetype" =~ ^video ]]; then
        kitty +icat --silent --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$(vidthumb "$file")"
        exit 1
    fi

    if [[ "$filetype" =~ "application/pdf" ]]; then
      TMPFILE=/tmp/pdf.tmp
      pdftoppm -jpeg -singlefile "$file" "$TMPFILE"
      kitty +icat --silent --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$TMPFILE".jpg
      rm -f "$TMPFILE" 
      exit 1
    fi

      pistol "$file"
  '';

  kittyCleanFile = ''
    #! /usr/bin/env bash
    kitty +icat --clear --silent --transfer-mode file
  '';
  
  configFile = ''
    set previewer ${placeholder "out"}/config/kittyPreview
    set cleaner ${placeholder "out"}/config/kittyClean

    set ratios 1:1

    cmd remove ''${{
      rm $fx
    }}
    map <delete> remove
  '';
  
  pistol = my.lib.wrapPackage {
    pkg = pkgs.pistol;
    name = "pistol";
    
    flags = [
      "--config ${placeholder "out"}/config/pistol.conf"
    ];
    
    files = {
      "config/pistol.conf" = pistolFile;
    };
  };

in wrapPackage {
  pkg = pkgs.lf;
  name = "lf";
  
  path = [ 
    vidthumbFile 
    pistol
    pkgs.poppler_utils
    pkgs.file
  ];
  
  flags = [
    "-config ${placeholder "out"}/config/lfrc"
  ];

  files = {
    "config/lfrc" = configFile;
  };
  
  scripts = {
    "config/kittyClean" = kittyCleanFile;
    "config/kittyPreview" = kittyPreviewFile;
  };
}