{ pkgs, my
, wrapPackage
, system
, inputs
}:
	
wrapPackage {
  pkg = pkgs.nix-index;
  name = "nix-locate";
  
  flags = [
    "--db ${placeholder "out"}/database"
  ];
  
  files = {
    "database/files" = inputs.nix-index-database.legacyPackages.${system}.database;
  };
}
