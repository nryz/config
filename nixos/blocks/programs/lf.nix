{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.lf;
in
{
  options.blocks.programs.lf = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      lf
      pistol
      file
      poppler_utils
      (writeShellScriptBin "vidthumb" ''
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
      '')
    ];

    hm.xdg.configFile."pistol/pistol.conf".text = ''
      image/* kitty +kitten icat %s
    '';

    hm.xdg.configFile."lf/lfrc".text = ''
      set previewer ~/.config/lf/lf_kitty_preview
      set cleaner ~/.config/lf/lf_kitty_clean

      set ratios 1:1

      cmd remove ''${{
        rm $fx
      }}
      map <delete> remove
    '';

    hm.xdg.configFile."lf/lf_kitty_preview" = {
      executable = true;
      text = ''
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
    };

    hm.xdg.configFile."lf/lf_kitty_clean" = {
      executable = true;
      text = ''
        #! /usr/bin/env bash
        kitty +icat --clear --silent --transfer-mode file
      '';
    };

  };
}
