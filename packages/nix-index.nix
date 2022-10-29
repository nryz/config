{ pkgs, my
, wrapPackage
, nix-index-database
}:
	
wrapPackage {
  pkg = pkgs.nix-index;
  name = "nix-locate";
  
  flags = [
    "--db ${placeholder "out"}/database"
  ];
  
  files = {
    "database/files" = nix-index-database;
  };
}
