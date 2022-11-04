{ pkgs, lib }:

with lib;
{
	mkDefPkg = args: rec {
		inherit (args) pkg desktop;
		name = pkg.meta.mainProgram;
		bin = "${pkg}/bin/${name}";
	};

  wrapPackage = {
    shell ? false,
    pkg,
    name,
    prefix ? {},
    path ? [],
    vars ? {},
    flags ? [],
    appendFlags ? [],
    files ? {},
    scripts ? {}, # executable files
    outputs ? {},
    extraPkgs  ? [],
    extraAttrs ? {},
    run ? [],
    share ? [],
    alias ? "",
    desktopItems ? [],
  }: let
    wrapperArgs = strings.escapeShellArgs ([
          "--inherit-argv0" 
			] ++ optionals (share != [] ) [	
          "--prefix" "XDG_DATA_DIRS" ":" (makeSearchPath "share" (unique share))
      ] ++ optionals (prefix != {}) (flatten (mapAttrsToList (n: v:
          [ "--prefix" "${n}" ] ++ v ) prefix)
      ) ++ optionals (path != []) [
          "--prefix" "PATH" ":" (makeBinPath path)
      ] ++ optionals (vars != {}) (concatMap (x:  ["--set"] ++ [x.name] ++ [x.value]) 
              (mapAttrsToList (n: v: { name = n;  value = v; }) vars)
      ) ++ optionals (flags != []) (concatMap (x: ["--add-flags"] ++ [x]) flags
      ) ++ optionals (appendFlags != []) (concatMap (x: ["--append-flags"] ++ [x]) appendFlags
      ) ++ optionals (shell && run != []) (concatMap (x: ["--run"] ++ [x]) run)
    );
    
    finalOutputs = mapAttrs (n: v: {
      install = false;
      files = {};
    } // v ) outputs;

  in pkgs.symlinkJoin {
    inherit name;
    
    inherit desktopItems;

    nativeBuildInputs = (optionals (desktopItems != []) [pkgs.copyDesktopItems])
                      ++ (if shell then [pkgs.makeWrapper] else [pkgs.makeBinaryWrapper]);
    
    outputs = ["out"] ++ (mapAttrsToList (n: v: "${n}") finalOutputs);
    

    paths = let 
      allPkgs = [ pkg ] ++ extraPkgs;
    in map (x: [x] ++ (optional (builtins.elem "man" x.outputs) [x.man])) allPkgs;

    postBuild = ''
      mkdir -p $out/bin
      
      ${if shell then ''
        rm $out/bin/${name}
      '' else ""}
      
      ${concatStrings (mapAttrsToList (n: v: ''
            mkdir -p $(dirname $out/${n})
          '' +
          (if isStorePath v then ''
            ln -s ${v} $out/${n} 
          '' else ''
            echo ""${strings.escapeShellArg v}"" >> $out/${n}
          '')) files)}
          
      ${concatStrings (mapAttrsToList (n: v: ''
            mkdir -p $(dirname $out/${n})
          '' +
          (if isStorePath v then ''
            ln -s ${v} $out/${n} 
          '' else ''
            echo ""${strings.escapeShellArg v}"" >> $out/${n}
          '') + ''
            chmod +x $out/${n}
          '') scripts)}
          
      ${concatStrings (mapAttrsToList (oName: oValue: let
          output = "$" + "${oName}";
        in if isStorePath oValue.files then ''
          ln -s ${oValue.files} ${output}
        '' else (concatStrings (mapAttrsToList (n: v: ''
            mkdir -p ${output}/$(dirname ${n})
          '' + (if isStorePath v then ''
            ln -s ${v} ${output}/${n}
          '' else ''
            echo ""${strings.escapeShellArg v}"" >> ${output}/${n}
        '' )) oValue.files ))) finalOutputs )}
                      
      makeWrapper "${pkg}/bin/${name}" "$out/bin/${name}" ${wrapperArgs}
      
      ${if (alias != "") then ''
        ln -s $out/bin/${name} $out/bin/${alias}
      '' else ""}
      
      ${if (desktopItems != []) then ''
        copyDesktopItems
      '' else ""}
    '' ;
    
    meta = {
      mainProgram = name;
      outputsToInstall = ["out"] ++ (mapAttrsToList (n: v: if v.install then "${n}" else "")) finalOutputs;
    };
  } // extraAttrs;
}
