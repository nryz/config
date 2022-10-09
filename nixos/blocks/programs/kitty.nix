{ config, lib, libs, pkgs, ... }:

with lib;
with libs.flake;
let
  cfg = config.blocks.programs.kitty;
in
{
  options.blocks.programs.kitty = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    hm.programs.kitty = {
      enable = true;

      font = config.blocks.desktop.font;
      
      # font = {
      #   package = pkgs.fira-code;
      #   name = "Fira Code";
      #   size = 8;
      # };

      #kitty_mod = ctrl+shift
      keybindings = {
        "kitty_mod+h" = "neighboring_window left";
        "kitty_mod+j" = "neighboring_window down";
        "kitty_mod+k" = "neighboring_window up";
        "kitty_mod+l" = "neighboring_window right";

        "kitty_mod+b" = "show_scrollback";
        "kitty_mod+enter" = "launch --cwd=current";

        "kitty_mod+1" = "goto_tab 1";
        "kitty_mod+2" = "goto_tab 2";
        "kitty_mod+3" = "goto_tab 3";
        "kitty_mod+4" = "goto_tab 4";
        "kitty_mod+5" = "goto_tab 5";
        "kitty_mod+6" = "goto_tab 6";
        "kitty_mod+7" = "goto_tab 7";
        "kitty_mod+8" = "goto_tab 8";
        "kitty_mod+9" = "goto_tab 9";
        "kitty_mod+0" = "goto_tab 10";

        "kitty_mod+n" = "next_layout";

        #zoom
        "kitty_mod+z" = "toggle_layout stack";

        #hints
        "kitty_mod+p>shift+f" = "kitten hints --type path";

        "kitty_mod+p>f" = "kitten hints --type path --program -";
        "kitty_mod+p>l" = "kitten hints --type line --program -";
        "kitty_mod+p>w" = "kitten hints --type word --program -";
        "kitty_mod+p>h" = "kitten hints --type hash --program -";
        "kitty_mod+p>n" = "kitten hints --type linenum --program -";
        "kitty_mod+p>y" = "kitten hints --type hyperlink --program -";
      };

      extraConfig = with config.scheme.withHashtag; ''
        enable_audio_bell no
        confirm_os_window_close 0
        
        italic_font ${config.blocks.desktop.font.name}
        bold_font ${config.blocks.desktop.font.name}
        bold_italic_font ${config.blocks.desktop.font.name}

        open_url_with ${config.defaults.browser}

        #fade/slant/separator/powerline
        tab_bar_style fade

        #angled/slanted/round
        tab_powerline_style angled

        tab_title_template "{index}:{title}"

        dynamic_background_opacity false

        background_opacity ${toString (255.0 / 255.0)}
        '' +
        ''
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
  };
}
