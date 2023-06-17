{
  my,
  pkgs,
  xdg,
  editor,
}: {
  "XDG_CACHE_HOME" = "${xdg.cacheHome}";
  "XDG_CONFIG_HOME" = "${xdg.configHome}";
  "XDG_DATA_HOME" = "${xdg.dataHome}";
  "XDG_STATE_HOME" = "${xdg.stateHome}";

  "EDITOR" = "${editor.name}";
  "VISUAL" = "${editor.name}";
  "LOCALE_ARCHIVE_2_27" = "${pkgs.glibcLocales}/lib/locale/locale-archive";

  "FONTCONFIG_FILE" = "${my.pkgs.fontconfig}";
}
