{ config, lib, pkgs, extraPkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.passage;
in
{
  options.blocks.programs.passage = with types; {
    enable = mkOpt bool false;
    storeLocation = mkOpt str "${config.home.homeDirectory}/.passage";
    storeClipTime = mkOpt int 10;
  };

  config = mkIf cfg.enable {
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
          --prefix PASSAGE_DIR : "${cfg.storeLocation}/store" \
          --prefix PASSAGE_IDENTITIES_FILE : "${cfg.storeLocation}/identities" \
          --prefix PASSAGE_RECIPIENTS_FILE : "${cfg.storeLocation}/.age-recipients" \
          --prefix PASSWORD_STORE_CLIP_TIME : "${builtins.toString cfg.storeClipTime}"
        '';
      })
      (pkgs.writeShellScriptBin "fzfPassage" ''
            #! /usr/bin/env bash
            set -eou pipefail
            LOC=${cfg.storeLocation}/store
            name="$(find "$LOC" -type f -name '*.age' | \
              sed -e "s|$LOC/||" -e 's|\.age$||' | \
              fzf --height 40% --reverse)"
            passage "''${@}" "$name" --clip
       '')
      (pkgs.writeShellScriptBin "fzfPassageSsh" ''
            #! /usr/bin/env bash
            set -eou pipefail
            LOC=${cfg.storeLocation}/store/ssh
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
