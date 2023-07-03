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
    let base16 = {
      base00: "${base00}"
      base01: "${base01}"
      base02: "${base02}"
      base03: "${base03}"
      base04: "${base04}"
      base05: "${base05}"
      base06: "${base06}"
      base07: "${base07}"
      base08: "${base08}"
      base09: "${base09}"
      base0A: "${base0A}"
      base0B: "${base0B}"
      base0C: "${base0C}"
      base0D: "${base0D}"
      base0E: "${base0E}"
      base0F: "${base0F}"
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

    links = {
      "modules" = ./modules;
    };

    files = {
      "config/config.nu" =
        (base16-vars + (builtins.readFile ./config/config.nu));

      "config/env.nu" =
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

            let-env NU_LIB_DIRS = ["${placeholder "out"}/modules/"]
            let-env NU_PLUGIN_DIRS = ["${placeholder "out"}/plugins/"]

            let-env PATH = ($env.PATH | append "${placeholder "out"}/bin/")

          ''
          + (builtins.readFile ./config/env.nu));
    };

    extraAttrs.shellPath = "/bin/nu";
  }
