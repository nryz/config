{ pkgs, lib }:

with lib;
{
  wrapPackage = {
    pkg,
    name,
    prefix ? {},
    path ? [],
    vars ? {},
    flags ? [],
    files ? {}
  }: let
    wrapperArgs = strings.escapeShellArgs ([
          "--inherit-argv0" 
      ] ++ optionals (prefix != {}) (flatten (mapAttrsToList (n: v:
          [ "--prefix" "${n}" ] ++ v
        ) prefix)
      ) ++ optionals (path != []) [
          "--prefix" "PATH" ":" (makeBinPath path)
      ] ++ optionals (vars != {}) (concatMap (x: 
          ["--set"] ++ [x.name] ++ [x.value]) 
              (mapAttrsToList (n: v: { name = n;  value = v; }) vars)
      ) ++ optionals (flags != []) (concatMap (x: ["--add-flags"] ++ [x]) flags)
    );
    
    fileCmds = mapAttrsToList (n: v:  
              "mkdir -p $out/${v.path}\n ln -s ${v.src} $out/${v.path}/${n}\n"
            ) files;

  in pkgs.runCommand name {nativeBuildInputs = [pkgs.makeBinaryWrapper];} (''
      mkdir -p $out/bin
    '' + concatStrings fileCmds
    + ''
      makeWrapper "${pkg}/bin/${name}" "$out/bin/${name}" ${wrapperArgs}
    '');
    
    
    
  wrapPackageJoin = {
    pkg,
    name,
    prefix ? {},
    path ? [],
    vars ? {},
    flags ? [],
    files ? {}
  }: let
    wrapperArgs = strings.escapeShellArgs ([
          "--inherit-argv0" 
      ] ++ optionals (prefix != {}) (flatten (mapAttrsToList (n: v:
          [ "--prefix" "${n}" ] ++ v
        ) prefix)
      ) ++ optionals (path != []) [
          "--prefix" "PATH" ":" (makeBinPath path)
      ] ++ optionals (vars != {}) (concatMap (x: 
          ["--set"] ++ [x.name] ++ [x.value]) 
              (mapAttrsToList (n: v: { name = n;  value = v; }) vars)
      ) ++ optionals (flags != []) (concatMap (x: ["--add-flags"] ++ [x]) flags)
    );
    
    fileCmds = mapAttrsToList (n: v:  
              "mkdir -p $out/${v.path}\n ln -s ${v.src} $out/${v.path}/${n}\n"
            ) files;

  in pkgs.symlinkJoin {
    inherit name;

    nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
    
    paths = [ pkg ];

    postBuild = ''
      mkdir -p $out/bin
    '' + concatStrings fileCmds + ''
      makeWrapper "${pkg}/bin/${name}" "$out/bin/${name}" ${wrapperArgs}
    '';
    
    meta = {
      inherit (pkg.meta) homepage description longDescription maintainers;
      mainProgram = name;
    };
  };
}
