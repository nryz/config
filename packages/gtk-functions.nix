{ pkgs, my
, font
, cursor
, wrapPackage
, ...
}:

with pkgs.lib;
let
	themeName = "custom";
	iconName = "arc";
	cursorName = "${cursor.name}";
in
rec {
	gtk2Config = ''
		gtk-font-name = "${font.name} ${toString font.size}"
		gtk-theme-name = "${themeName}"
		gtk-icon-theme-name = "${iconName}"
		gtk-cursor-theme-name= = "${cursorName}"
	'';
	
	gtkConfig = ''
		[Settings]
		gtk-font-name=${font.name} ${toString font.size}
		gtk-icon-theme-name=${iconName}
		gtk-theme-name=${themeName}
		gtk-cursor-theme-name=${cursorName}
	'';
	
	wrapGtk2Package = args: wrapPackage ({
		prefix = {
			"XCURSOR_PATH" = [ ":" "${placeholder "out"}/theme/share/icons"];
		};

		vars = {
			"GTK2_RC_FILES" = "${placeholder "out"}/config";
		};
		
		files = {
			"config/gtk-2.0/gtkrc" = gtk2Config;
		};
	} // args);
	
	wrapGtkPackage = args: wrapPackage ({
	
		prefix = {
			"XCURSOR_PATH" = [ ":" "${placeholder "out"}/theme/share/icons"];
		};
		
		vars = {
			"GTK2_RC_FILES" = "${placeholder "out"}/config";
	    "XDG_CONFIG_HOME" = "${placeholder "out"}/config";
		};
		
		files = {
			"config/gtk-2.0/gtkrc" = gtk2Config;
			"config/gtk-3.0/settings.ini" = gtkConfig;
			"config/gtk-4.0/settings.ini" = gtkConfig;
		};
	} // args );
	
	wrapGtkPackages = pkgs: 
		listToAttrs (map (pkg: let 
			name = pkg.meta.mainProgram or pkg.pname; 
		in nameValuePair name ( wrapGtkPackage {inherit pkg name;} )) pkgs);
}

