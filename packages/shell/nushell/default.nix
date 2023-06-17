{
  inputs,
  pkgs,
  my,
  xdg,
  stdenvNoCC,
  env ? {},
  editor,
  base16,
  wrapPackage,
}: let
  lib = pkgs.lib;

  combined-env =
    import ../env.nix {
      inherit my pkgs xdg editor;
    }
    // env;

  base16-vars = with base16.withHashtag; ''
    let base00 = "${base00}"
    let base01 = "${base01}"
    let base02 = "${base02}"
    let base03 = "${base03}"
    let base04 = "${base04}"
    let base05 = "${base05}"
    let base06 = "${base06}"
    let base07 = "${base07}"
    let base08 = "${base08}"
    let base09 = "${base09}"
    let base0A = "${base0A}"
    let base0B = "${base0B}"
    let base0C = "${base0C}"
    let base0D = "${base0D}"
    let base0E = "${base0E}"
    let base0F = "${base0F}"
  '';

  scopedNuFile = str:
    ''
      if true {
    ''
    + str
    + ''
      }
    '';
in
  wrapPackage {
    pkg = pkgs.nushell;
    name = "nu";

    flags = [
      "--config ${placeholder "out"}/config/config.nu"
      "--env-config ${placeholder "out"}/config/env.nu"
    ];

    files = {
      "config/config.nu" =
        scopedNuFile
        (base16-vars + (builtins.readFile ./config.nu));

      "config/env.nu" =
        scopedNuFile
        (base16-vars
          + ''
            load-env {
              ${lib.concatStrings (lib.mapAttrsToList (n: v: (
                if lib.hasInfix "$HOME" v
                then ''
                  "${n}": $"("${v}" | str replace -s '$HOME' $"($env.HOME)")"
                ''
                else ''
                  "${n}": "${v}"
                ''
              ))
              combined-env)}
            }
          ''
          + (builtins.readFile ./env.nu));
    };

    extraAttrs.shellPath = "/bin/nu";
  }
