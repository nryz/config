{ pkgs, lib }:

with lib;
{
	mkDefPkg = pkg: rec {
		inherit pkg;
		name = pkg.meta.mainProgram;
		bin = "${pkg}/bin/${name}";
	};

  wrapPackageJoin = {
    pkg,
    name,
    prefix ? {},
    path ? [],
    vars ? {},
    flags ? [],
    files ? {},
    outputs ? {},
    extraPkgs  ? [],
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
    
    filesCmd = concatStrings (mapAttrsToList (n: v: ''
        mkdir -p $(dirname $out/${n})
        ln -s ${v} $out/${n} 
      '') files);
      
    outputsCmd = if (outputs != {}) then ( concatStrings (mapAttrsToList (n: v: let
        output = "$" + "${n}";
      in concatStrings (mapAttrsToList (n: v: ''
        mkdir -p ${output}/$(dirname ${n})
      '' + (if isStorePath v then ''
        ln -s ${v} ${output}/${n}
      '' else ''
        echo "${v}" >> ${output}/${n}
      '' )) v )) outputs )) else "";

  in pkgs.symlinkJoin {
    inherit name;

    nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
    
    outputs = ["out"] ++ (mapAttrsToList (n: v: "${n}") outputs);
    
    paths = [ pkg ] ++ extraPkgs ++ optional (builtins.elem "man" pkg.outputs) [ pkg.man ];

    postBuild = ''
        mkdir -p $out/bin
      ''
      + filesCmd  
      + outputsCmd
      + ''
        makeWrapper "${pkg}/bin/${name}" "$out/bin/${name}" ${wrapperArgs}
      '' ;
    
    meta = {
      mainProgram = name;
      outputsToInstall = ["out"];
    };
  };
}
