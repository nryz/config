{ pkgs, lib }:

with lib;
{
	mkDefPkg = pkg: rec {
		inherit pkg;
		name = pkg.meta.mainProgram;
		bin = "${pkg}/bin/${name}";
	};

  wrapPackage = {
    pkg,
    name,
    prefix ? {},
    path ? [],
    vars ? {},
    flags ? [],
    files ? {},
    scripts ? {}, # executable files
    outputs ? {},
    extraPkgs  ? [],
    extraAttrs ? {},
  }: let
    wrapperArgs = strings.escapeShellArgs ([
          "--inherit-argv0" 
      ] ++ optionals (prefix != {}) (flatten (mapAttrsToList (n: v:
          [ "--prefix" "${n}" ] ++ v ) prefix)
      ) ++ optionals (path != []) [
          "--prefix" "PATH" ":" (makeBinPath path)
      ] ++ optionals (vars != {}) (concatMap (x: 
          ["--set"] ++ [x.name] ++ [x.value]) 
              (mapAttrsToList (n: v: { name = n;  value = v; }) vars)
      ) ++ optionals (flags != []) (concatMap (x: ["--add-flags"] ++ [x]) flags)
    );
    
    finalOutputs = mapAttrs (n: v: {
      install = false;
      files = {};
    } // v ) outputs;

  in pkgs.symlinkJoin {
    inherit name;

    nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
    
    outputs = ["out"] ++ (mapAttrsToList (n: v: "${n}") finalOutputs);
    

    paths = let 
      allPkgs = [ pkg ] ++ extraPkgs;
    in map (x: [x] ++ (optional (builtins.elem "man" x.outputs) [x.man])) allPkgs;

    postBuild = ''
      mkdir -p $out/bin
      
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
            echo "${v}" >> ${output}/${n}
        '' )) oValue.files ))) finalOutputs )}
        
        
      makeWrapper "${pkg}/bin/${name}" "$out/bin/${name}" ${wrapperArgs}
    '' ;
    
    meta = {
      mainProgram = name;
      outputsToInstall = ["out"] ++ (mapAttrsToList (n: v: if v.install then "${n}" else "")) finalOutputs;
    };
  } // extraAttrs;
}
