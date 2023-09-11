{
  pkgs,
  my,
  base16,
  font,
  terminal,
  cursor,
  backgrounds,
  wrapPackage,
  drivers ? {},
}: let
  pkg = pkgs.herbstluftwm;

  hc = "${pkg}/bin/herbstclient";

  pamixer = "${pkgs.pamixer}/bin/pamixer";

  startx = my.pkgs.startx.override {inherit drivers;};

  yambar = my.pkgs.yambar.override {
    workspacesScript = ''
      #!/usr/bin/env bash
      echo "tags|string|$(${pkg}/bin/herbstclient tag_status | ${pkgs.coreutils}/bin/tr "\t" " ")"

      echo "client_count|string|$(${pkg}/bin/herbstclient get_attr tags.focus.client_count)"
      echo ""
    '';
  };

  cursorPath = "${cursor.package}/share/icons/${cursor.name}/cursors/left_ptr";
in
  wrapPackage {
    pkg = pkg;
    name = "herbstluftwm";

    flags = [
      "--autostart ${placeholder "out"}/config/autostart"
      "--locked"
    ];

    files = {
      "config/xinitrc" = ''
        source ${startx}/config/xinitrc

        ${placeholder "out"}/bin/herbstluftwm
      '';
    };

    shellScripts = {
      "config/autostart" = with base16.withHashtag; ''

        hc() {
          ${hc} "$@"
        }

        hc emit_hook reload

        # Startup
        kill $(pidof picom)
        ${my.pkgs.picom}/bin/picom -b
        ${pkgs.feh}/bin/feh --bg-fill --no-fehbg --randomize ${backgrounds} &
        ${pkgs.xorg.xsetroot}/bin/xsetroot -xcf ${cursorPath} ${toString cursor.size}


        # remove all existing keybindings
        hc keyunbind --all

        # keybindings
        Mod=Mod4

        hc keybind $Mod-b spawn ${placeholder "out"}/scripts/toggleBar

        hc keybind XF86AudioMute spawn ${pamixer} -t
        hc keybind XF86AudioLowerVolume spawn ${pamixer} -d 5
        hc keybind XF86AudioRaiseVolume spawn ${pamixer} -i 5

        #launchers
        hc keybind $Mod-space spawn ${my.pkgs.rofi}/bin/rofi -show run
        hc keybind $Mod-g spawn ${placeholder "out"}/scripts/tag
        hc keybind $Mod-m spawn ${placeholder "out"}/scripts/window

        hc keybind $Mod-Shift-r reload
        hc keybind $Mod-w close_and_remove
        hc keybind $Mod-Return spawn ${terminal.bin}

        # basic movement in tiling and floating mode
        # focusing clients
        hc keybind $Mod-h     focus left
        hc keybind $Mod-j     focus down
        hc keybind $Mod-k     focus up
        hc keybind $Mod-l     focus right

        # moving clients in tiling and floating mode
        hc keybind $Mod-Shift-h     shift left
        hc keybind $Mod-Shift-j     shift down
        hc keybind $Mod-Shift-k     shift up
        hc keybind $Mod-Shift-l     shift right

        # splitting frames
        # create an empty frame at the specified direction
        hc keybind $Mod-u chain , split  bottom  0.5 , focus down
        hc keybind $Mod-o chain , split   right  0.5 , focus right

        hc keybind $Mod-Shift-u chain , split bottom 0.5 , shift down
        hc keybind $Mod-Shift-o chain , split  right 0.5 , shift right

        # let the current frame explode into subframes
        hc keybind $Mod-Control-space split explode

        # resizing frames and floating clients
        resizestep=0.1
        hc keybind $Mod-Control-h       resize left +$resizestep
        hc keybind $Mod-Control-j       resize down +$resizestep
        hc keybind $Mod-Control-k       resize up +$resizestep
        hc keybind $Mod-Control-l       resize right +$resizestep
        hc keybind $Mod-Control-Left    resize left +$resizestep
        hc keybind $Mod-Control-Down    resize down +$resizestep
        hc keybind $Mod-Control-Up      resize up +$resizestep
        hc keybind $Mod-Control-Right   resize right +$resizestep


        #set default layout
        hc set default_frame_layout max


        # tags
        tag_names=( {1..9} )
        tag_keys=( {1..9} 0 )

        hc rename default "''${tag_names[0]}" || true
        for i in "''${!tag_names[@]}" ; do
            hc add "''${tag_names[$i]}"
            key="''${tag_keys[$i]}"
            if [ -n "$key" ] ; then
                hc keybind "$Mod-$key" use_index "$i"
                hc keybind "$Mod-Shift-$key" move_index "$i"
            fi
        done

        # layouting
        hc keybind $Mod-f fullscreen toggle
        hc keybind $Mod-Shift-f set_attr clients.focus.floating toggle
        hc keybind $Mod-p pseudotile toggle

        hc keybind $Mod-i cycle_layout 1 max grid

        # mouse
        hc mouseunbind --all
        hc mousebind $Mod-Button1 move
        hc mousebind $Mod-Button2 zoom
        hc mousebind $Mod-Button3 resize

        # focus
        hc keybind $Mod-BackSpace   cycle_monitor
        hc keybind $Mod-Tab         cycle +1
        hc keybind $Mod-Shift-Tab   cycle -1
        hc keybind $Mod-y jumpto urgent

        # theme
        hc attr theme.tiling.reset 1
        hc attr theme.floating.reset 1

        # frame
        hc set frame_gap 0
        hc set show_frame_decorations 'if_multiple'
        hc set frame_padding 0
        hc set frame_border_width 1
        hc set frame_border_inner_width 0
        hc set frame_border_inner_color black
        hc set frame_border_active_color '${base09}'
        hc set frame_border_normal_color '${base01}'

        hc set frame_bg_normal_color '${base00}'
        hc set frame_bg_active_color '${base00}'
        hc set frame_bg_transparent off
        hc set frame_transparent_width 0
        hc set smart_frame_surroundings off

        hc substitute ALGO settings.default_frame_layout \
            foreach T tags.by-name. \
            sprintf ATTR '%c.tiling.root.algorithm' T \
            set_attr ATTR ALGO


        # title
        hc attr theme.title_height 12
        hc attr theme.title_when multiple_tabs
        hc attr theme.title_font '${font.name}:pixelsize=${toString font.size}'
        # hc attr theme.title_font '-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-*'
        hc attr theme.title_depth 3  # space below the title's baseline
        hc attr theme.title_color '${base05}'
        hc attr theme.normal.title_color '${base05}'
        hc attr theme.title_align center

        # tab
        hc attr theme.tab_color '${base00}'
        hc attr theme.tab_outer_width 0
        hc attr theme.tab_outer_color black
        hc attr theme.active.tab_color '${base00}'
        hc attr theme.active.tab_outer_color ${base00}'
        hc attr theme.active.tab_title_color '${base05}'
        hc attr theme.normal.tab_color '${base00}'
        hc attr theme.normal.tab_outer_color '${base00}'
        hc attr theme.normal.tab_title_color '${base05}'

        # border
        hc set window_gap 0
        hc set smart_window_surroundings off
        hc attr theme.border_width 0
        hc attr theme.inner_width 0
        hc attr theme.outer_width 0
        hc attr theme.inner_color black
        hc attr theme.outer_color black
        hc attr theme.active.color '${base01}'
        hc attr theme.normal.color '${base01}'
        hc attr theme.urgent.color '${base01}'
        hc attr theme.urgent.inner_color '${base01}'

        hc attr theme.floating.border_width 4
        hc attr theme.floating.outer_width 1
        hc attr theme.floating.outer_color black


        hc set hide_covered_windows true

        hc set mouse_recenter_gap 0

        # rules
        hc unrule -F
        hc rule focus=on # normally focus new clients
        hc rule floatplacement=center
        hc rule fixedsize floating=on

        hc rule windowtype~'_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)' floating=on
        hc rule windowtype='_NET_WM_WINDOW_TYPE_DIALOG' focus=on
        hc rule windowtype~'_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK|DESKTOP)' manage=off

        hc rule class=mpv tag=2

        hc set tree_style '╾│ ├└╼─┐'

        # unlock, just to be sure
        hc unlock

        hc detect_monitors
      '';

      "scripts/window" = ''
        input=()
        for tag in $(${hc} complete 1 move); do
          input+=("Move window to tag $tag" "${hc} move $tag")
        done

        input+=("Fullscreen" "${hc} fullscreen toggle")
        input+=("Floating" "${hc} set_attr clients.focus.floating toggle")

        ${my.pkgs.rofi}/scripts/list "''${input[@]}"
      '';

      "scripts/tag" = ''
        input=()
        for tag in $(${hc} complete 1 use); do
          input+=("Go to tag $tag" "${hc} use $tag")
        done

        ${my.pkgs.rofi}/scripts/list "''${input[@]}"
      '';

      "scripts/startx" = ''
        ${startx}/bin/startx ${placeholder "out"}/config/xinitrc
      '';
    };
  }
