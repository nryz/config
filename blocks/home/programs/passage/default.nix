{ config, lib, pkgs, extraPkgs, ... }:

with lib;
with lib.my;
{
  options = with types; {
    passage.storeLocation = mkOpt str "${config.home.homeDirectory}/.passage";
    passage.storeClipTime = mkOpt int 10;
  };

  config = {
    home.packages = with pkgs; [
      pinentry_curses
      age
      rage
      age-plugin-yubikey
      yubikey-manager-qt
      yubioath-desktop
      (extraPkgs.passage.override {
        postInstall = ''
          wrapProgram $out/bin/passage \
          --prefix PASSAGE_AGE : "rage" \
          --prefix PASSAGE_DIR : "${config.passage.storeLocation}/store" \
          --prefix PASSAGE_IDENTITIES_FILE : "${config.passage.storeLocation}/identities" \
          --prefix PASSAGE_RECIPIENTS_FILE : "${config.passage.storeLocation}/.age-recipients" \
          --prefix PASSWORD_STORE_CLIP_TIME : "${builtins.toString config.passage.storeClipTime}"
        '';
      })
      (pkgs.writeShellScriptBin "fzfPassage" ''
            #! /usr/bin/env bash
            set -eou pipefail
            LOC=${config.passage.storeLocation}/store
            name="$(find "$LOC" -type f -name '*.age' | \
              sed -e "s|$LOC/||" -e 's|\.age$||' | \
              fzf --height 40% --reverse)"
            passage "''${@}" "$name" --clip
       '')
      (pkgs.writeShellScriptBin "fzfPassageSsh" ''
            #! /usr/bin/env bash
            set -eou pipefail
            LOC=${config.passage.storeLocation}/store/ssh
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
