{lib}:
with lib; {
  mkDefPkg = pkg: desktop: rec {
    inherit pkg desktop;
    name = pkg.meta.mainProgram;
    bin = "${pkg}/bin/${name}";
  };

  wrapPackage = {
    pkgs,
    shell ? false,
    pkg,
    name,
    paths ? {},
    binPath ? [],
    vars ? {},
    flags ? [],
    appendFlags ? [],
    links ? {},
    files ? {},
    shellScripts ? {},
    outputs ? {},
    extraPkgs ? [],
    extraAttrs ? {},
    run ? [],
    alias ? "",
    desktopItems ? [],
  }: let
    wrapperArgs = strings.escapeShellArgs (
      [
        "--inherit-argv0"
      ]
      ++ optionals (paths != {}) (
        flatten ((
            mapAttrsToList
            (
              pathName: pathValues: let
                split = splitString "," pathName;
              in [
                "--prefix"
                (elemAt split 0)
                (elemAt split 1)
                (concatStringsSep (elemAt split 1) (unique pathValues))
              ]
            )
          )
          paths)
      )
      ++ optionals (binPath != []) [
        "--prefix"
        "PATH"
        ":"
        (makeBinPath binPath)
      ]
      ++ optionals (vars != {}) (
        concatMap (x: ["--set"] ++ [x.name] ++ [x.value])
        (mapAttrsToList (n: v: {
            name = n;
            value = v;
          })
          vars)
      )
      ++ optionals (flags != []) (
        concatMap (x: ["--add-flags"] ++ [x]) flags
      )
      ++ optionals (appendFlags != []) (
        concatMap (x: ["--append-flags"] ++ [x]) appendFlags
      )
      ++ optionals (shell && run != []) (concatMap (x: ["--run"] ++ [x]) run)
    );

    finalOutputs = mapAttrs (n: v:
      {
        install = false;
        files = {};
      }
      // v)
    outputs;
  in
    pkgs.symlinkJoin {
      inherit name;

      inherit desktopItems;

      nativeBuildInputs =
        (optionals (desktopItems != []) [pkgs.copyDesktopItems])
        ++ (
          if shell
          then [pkgs.makeWrapper]
          else [pkgs.makeBinaryWrapper]
        );

      outputs = ["out"] ++ (mapAttrsToList (n: v: "${n}") finalOutputs);

      paths = let
        allPkgs = [pkg] ++ extraPkgs;
      in
        map (x: [x] ++ (optional (builtins.elem "man" x.outputs) [x.man])) allPkgs;

      postBuild = ''
        mkdir -p $out/bin

        ${
          if shell
          then ''
            rm $out/bin/${name}
          ''
          else ""
        }

        ${concatStrings (mapAttrsToList (
            n: v: ''
              mkdir -p $(dirname $out/${n})
              ln -s ${v} $out/${n}
            ''
          )
          links)}

        ${concatStrings (mapAttrsToList (n: v:
          ''
            mkdir -p $(dirname $out/${n})
          ''
          + (
            if isStorePath v
            then ''
              ln -s ${v} $out/${n}
            ''
            else ''
              echo ""${strings.escapeShellArg v}"" >> $out/${n}
            ''
          ))
        files)}

        ${concatStrings (mapAttrsToList (
            n: v: let
              script =
                ''
                  #!${pkgs.bash}/bin/bash

                ''
                + v;
            in
              if isStorePath v
              then builtins.abort "${n} should not be a store path in shellScripts"
              else ''
                mkdir -p $(dirname $out/${n})

                echo ""${strings.escapeShellArg script}"" >> $out/${n}
                chmod +x $out/${n}
              ''
          )
          shellScripts)}

        ${concatStrings (mapAttrsToList (oName: oValue: let
          output = "$" + "${oName}";
        in
          if isStorePath oValue.files
          then ''
            ln -s ${oValue.files} ${output}
          ''
          else
            (concatStrings (mapAttrsToList (n: v:
              ''
                mkdir -p ${output}/$(dirname ${n})
              ''
              + (
                if isStorePath v
                then ''
                  ln -s ${v} ${output}/${n}
                ''
                else ''
                  echo ""${strings.escapeShellArg v}"" >> ${output}/${n}
                ''
              ))
            oValue.files)))
        finalOutputs)}

        makeWrapper "${pkg}/bin/${name}" "$out/bin/${name}" ${wrapperArgs}

        ${
          if (alias != "")
          then ''
            ln -s $out/bin/${name} $out/bin/${alias}
          ''
          else ""
        }

        ${
          if (desktopItems != [])
          then ''
            copyDesktopItems
          ''
          else ""
        }
      '';

      meta = {
        mainProgram = name;
        outputsToInstall =
          ["out"]
          ++ (mapAttrsToList (n: v:
            if v.install
            then "${n}"
            else ""))
          finalOutputs;
      };
    }
    // extraAttrs;
}
