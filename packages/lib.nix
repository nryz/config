{ pkgs } :


let
  lib = pkgs.lib;
in
{
  wrapPackage = {
    pkg,
    name,
    prefix ? [],
    vars ? [],
    flags ? [],
    files ? {}
  }: let
    wrapperArgs = lib.strings.escapeShellArgs ([
      "--inherit-argv0" 
      ] ++ lib.optionals (prefix != []) [
        "--prefix" "PATH" ":" (lib.makeBinPath prefix)
      ] ++ lib.optionals (vars != []) (lib.concatMap (x: 
              ["--set"] ++ [x.name] ++ [x.value]) 
                  (lib.mapAttrsToList (n: v: {
                        name = n; 
                        value = v;
                          }) vars))
      ++ lib.optionals (flags != []) (lib.concatMap (x: ["--add-flags"] ++ [x]) flags)
    );
    
    fileCmds = lib.mapAttrsToList (n: v:  
              "mkdir -p $out/${v.path}\n ln -s ${v.src} $out/${v.path}/${n}\n"
            ) files;

  in pkgs.runCommand name {nativeBuildInputs = [pkgs.makeBinaryWrapper];} (''
      mkdir -p $out/bin
    '' + lib.concatStrings fileCmds
    + ''
      makeWrapper "${pkg}/bin/${name}" "$out/bin/${name}" ${wrapperArgs}
    '');
}
