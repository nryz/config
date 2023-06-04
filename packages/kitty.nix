{
  pkgs,
  my,
  base16,
  font,
  wrapPackage,
}: let
  lib = pkgs.lib;
in
  wrapPackage {
    pkg = pkgs.kitty;
    name = "kitty";

    vars = {
      "KITTY_CONFIG_DIRECTORY" = "${placeholder "out"}/config";
    };

    files = {
      "config/kitty.conf" = with base16.withHashtag; ''
        enable_audio_bell no
        confirm_os_window_close 0

        open_url_with qutebrowser

        tab_title_template "{index}:{title}"

        # kitty_mod == ctrl-shift
        map kitty_mod+h  neighboring_window left
        map kitty_mod+j  neighboring_window down
        map kitty_mod+k  neighboring_window up
        map kitty_mod+l  neighboring_window right

        map kitty_mod+b  show_scrollback
        map kitty_mod+enter  launch --cwdcurrent

        map kitty_mod+1  goto_tab 1
        map kitty_mod+2  goto_tab 2
        map kitty_mod+3  goto_tab 3
        map kitty_mod+4  goto_tab 4
        map kitty_mod+5  goto_tab 5
        map kitty_mod+6  goto_tab 6
        map kitty_mod+7  goto_tab 7
        map kitty_mod+8  goto_tab 8
        map kitty_mod+9  goto_tab 9
        map kitty_mod+0  goto_tab 10

        map kitty_mod+n  next_layout

        #zoom
        map kitty_mod+z  toggle_layout stack

        #hints
        map kitty_mod+p>shift+f  kitten hints --type path

        map kitty_mod+p>f  kitten hints --type path --program -
        map kitty_mod+p>l  kitten hints --type line --program -
        map kitty_mod+p>w  kitten hints --type word --program -
        map kitty_mod+p>h  kitten hints --type hash --program -
        map kitty_mod+p>n  kitten hints --type linenum --program -
        map kitty_mod+p>y  kitten hints --type hyperlink --program -

        # Theme
        tab_bar_style fade
        tab_powerline_style angled

        dynamic_background_opacity false
        background_opacity 1.0

        font_size ${toString font.size}
        font_family ${font.name}
        italic_font ${font.name}
        bold_font ${font.name}
        bold_italic_font ${font.name}

        background ${base00}
        foreground ${base05}
        selection_background ${base05}
        selection_foreground ${base00}
        url_color ${base04}
        cursor ${base05}
        active_border_color ${base03}
        inactive_border_color ${base01}
        active_tab_background ${base08}
        active_tab_foreground ${base05}
        inactive_tab_background ${base01}
        inactive_tab_foreground ${base04}
        tab_bar_background ${base01}

        # normal
        color0 ${base00}
        color1 ${base08}
        color2 ${base0B}
        color3 ${base0A}
        color4 ${base0D}
        color5 ${base0E}
        color6 ${base0C}
        color7 ${base05}

        # bright
        color8 ${base03}
        color9 ${base09}
        color10 ${base09}
        color11 ${base0C}
        color12 ${base04}
        color13 ${base06}
        color14 ${base0F}
        color15 ${base07}
      '';
    };
  }
