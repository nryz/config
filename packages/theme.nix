{ lib , pkgs , font , base16, cursor }:

let
  version = "20210322";
in pkgs.symlinkJoin {
  name = "custom-theme";
  
  paths = with pkgs; [
    (stdenv.mkDerivation {
      pname = "materia-theme";
      inherit version;
  
      src = fetchFromGitHub {
        owner = "nana-4";
        repo = "materia-theme";
        rev = "v${version}";
        sha256 = "1fsicmcni70jkl4jb3fvh7yv0v9jhb8nwjzdq8vfwn256qyk0xvl";
      };
	
      nativeBuildInputs = [
        bc
        optipng
        sassc

        (runCommandLocal "rendersvg" { } ''
          mkdir -p $out/bin
          ln -s ${resvg}/bin/resvg $out/bin/rendersvg
        '')
      ];

      dontConfigure = true;

      # Fixes problem "Fontconfig error: Cannot load default config file"
      FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ cantarell-fonts ]; };

      theme = with base16; lib.generators.toKeyValue { } {
        ACCENT_BG = base0B;
        ACCENT_FG = base00;
        BG = base00;
        BTN_BG = base01;
        BTN_FG = base06;
        FG = base05;
        HDR_BG = base01;
        HDR_BTN_BG = base01;
        HDR_BTN_FG = base05;
        HDR_FG = base05;
        MATERIA_SURFACE = base01;
        MATERIA_VIEW = base01;
        MENU_BG = base01;
        MENU_FG = base00;
        SEL_BG = base0D;
        SEL_FG = base0E;
        TXT_BG = base00;
        TXT_FG = base05;
        WM_BORDER_FOCUS = base00;
        WM_BORDER_UNFOCUS = base00;

        MATERIA_COLOR_VARIANT = "dark";
        MATERIA_STYLE_COMPACT = "True";
        UNITY_DEFAULT_LAUNCHER_STYLE = "False";
      };

      passAsFile = [ "theme" ];

      postPatch = ''
        patchShebangs .

        sed -e '/handle-horz-.*/d' -e '/handle-vert-.*/d' \
          -i ./src/gtk-2.0/assets.txt
      '';

      buildPhase = ''
        export HOME="$NIX_BUILD_ROOT"
        ./change_color.sh \
           -i False \
           -t $out/share/themes \
           -o "custom" \
           "$themePath"
      '';
    })
    arc-icon-theme
    moka-icon-theme
    cursor.package
  ];
}

