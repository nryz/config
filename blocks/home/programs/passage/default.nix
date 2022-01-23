{ config, lib, pkgs, ... }:

with lib;
with lib.my;
{
  options = with types; {
    passage.storeLocation = mkOpt str "${config.home.homeDirectory}/.passage/store";
    passage.identitiesLocation = mkOpt str "${config.home.homeDirectory}/.passage/identities";
    passage.storeClipTime = mkOpt int 10;
  };

  config = {
    home.packages = with pkgs; [
      gopass
      age
      (passage.override {
        postInstall = ''
          wrapProgram $out/bin/passage \
          --prefix PASSAGE_DIR : "${config.passage.storeLocation}" \
          --prefix PASSAGE_IDENTITIES_FILE : "${config.passage.identitiesLocation}" \
          --prefix PASSWORD_STORE_CLIP_TIME : "${builtins.toString config.passage.storeClipTime}"
        '';
      })
      (pkgs.writeShellScriptBin "fzfPassage" ''
            #! /usr/bin/env bash
            set -eou pipefail
            LOC=${config.passage.storeLocation}
            name="$(find "$LOC" -type f -name '*.age' | \
              sed -e "s|$LOC/||" -e 's|\.age$||' | \
              fzf --height 40% --reverse)"
            passage "''${@}" "$name" --clip
       '')
      (pkgs.writeShellScriptBin "fzfPassageSsh" ''
            #! /usr/bin/env bash
            set -eou pipefail
            LOC=${config.passage.storeLocation}/ssh
            name="$(find "$LOC" -type f -name '*.age' | \
              sed -e "s|$LOC/||" -e 's|\.age$||' | \
              fzf --height 40% --reverse)"

            if [ -n "$name" ]; then
              privatekey=$(passage show ssh/$name)
              ssh-add - <<< ''${privatekey}
            fi
      '')
    ];
  };
}
