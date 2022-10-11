{ pkgs, my, ... }:

let
    configFile = with my.theme.base16.withHashtag; pkgs.writeText "zathura-config" ''
			set font                        "${my.theme.font.name} ${toString my.theme.font.size}"
			set default-bg                  "${base00}"
			set default-fg                  "${base01}"

			set statusbar-fg                "${base04}"
			set statusbar-bg                "${base01}"

			set inputbar-bg                 "${base00}"
			set inputbar-fg                 "${base02}"

			set notification-error-bg       "${base08}"
			set notification-error-fg       "${base00}"

			set notification-warning-bg     "${base08}"
			set notification-warning-fg     "${base00}"

			set highlight-color             "${base0A}"
			set highlight-active-color      "${base0D}"

			set completion-highlight-fg     "${base02}"
			set completion-highlight-bg     "${base0C}"

			set completion-bg               "${base02}"
			set completion-fg               "${base0C}"

			set notification-bg             "${base0B}"
			set notification-fg             "${base00}"

			set recolor-lightcolor          "${base00}"
			set recolor-darkcolor           "${base06}"
			set recolor                     "true"

			set recolor-keephue             "true"   
		'';
in my.lib.wrapPackageJoin {
  pkg = pkgs.zathura;
  name = "zathura";
	
	flags = [
		"--config-dir ${placeholder "out"}/config"
	];

  files = {
    "zathurarc" = {
      path = "config";
      src = configFile;
    };
  };
}
