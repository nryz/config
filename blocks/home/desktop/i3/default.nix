{ config, lib, pkgs, flakePath, ...}:

with lib;
with lib.my;
let
  cfg = config.blocks.desktop.i3;
  
  package = pkgs.i3-gaps;
in
{
  options.blocks.desktop.i3 = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {

    blocks.desktop.windowManager.name = "i3";
    blocks.desktop.xserver.enable = true;
    blocks.desktop.xserver.wmCommand = '' exec ${package}/bin/i3 '';
    
    xdg.configFile."i3/config" = let 
      configFile = with config.scheme.withHashtag;  pkgs.writeText "i3.config" ''
        set $mod Mod4

        floating_modifier $mod

        hide_edge_borders none
        focus_wrapping no
        focus_follows_mouse no

        default_orientation horizontal
        workspace_layout tabbed
        workspace_auto_back_and_forth yes
        
        title_align center
        
        gaps inner 8
        gaps outer 8 
        
        default_border pixel 2
        default_floating_border pixel 2
        
        client.focused           ${base08} ${base00} ${base02} ${base0E} ${base08}
        client.focused_inactive  ${base02} ${base00} ${base02} ${base0E} ${base02}
        client.unfocused         ${base02} ${base00} ${base02} ${base0E} ${base02}
        client.urgent            ${base0E} ${base00} ${base02} ${base0E} ${base0E}
        client.placeholder       ${base00} ${base00} ${base02} ${base0E} ${base00}
        client.background        ${base00}
        
        bindsym $mod+Return exec ${config.defaults.terminal}
        bindsym $mod+w kill
        
        bindsym XF86AudioRaiseVolume exec IncreaseVolume
        bindsym XF86AudioLowerVolume exec DecreaseVolume
        bindsym XF86AudioMute exec ToggleVolume
        
        bindsym $mod+Tab focus next sibling
        bindsym $mod+Shift+Tab focus prev sibling
        
        # change focus
        bindsym $mod+h focus left
        bindsym $mod+j focus down
        bindsym $mod+k focus up
        bindsym $mod+l focus right
        
        # move focused window
        bindsym $mod+Shift+H move left
        bindsym $mod+Shift+J move down
        bindsym $mod+Shift+K move up
        bindsym $mod+Shift+L move right
        
        bindsym $mod+b split h
        bindsym $mod+v split v
        bindsym $mod+f fullscreen
        
        # change container layout
        bindsym $mod+s layout stacking
        bindsym $mod+t layout tabbed
        bindsym $mod+e layout toggle split

        bindsym $mod+Shift+space floating toggle
        bindsym $mod+space focus mode_toggle
        
        bindsym $mod+a focus parent
        bindsym $mod+d focus child

        # switch to workspace
        bindsym $mod+1 workspace 1
        bindsym $mod+2 workspace 2
        bindsym $mod+3 workspace 3
        bindsym $mod+4 workspace 4
        bindsym $mod+5 workspace 5
        bindsym $mod+6 workspace 6
        bindsym $mod+7 workspace 7
        bindsym $mod+8 workspace 8
        bindsym $mod+9 workspace 9
        bindsym $mod+0 workspace 10    
        
        # move focused container to workspace
        bindsym $mod+Shift+exclam move container to workspace 1
        bindsym $mod+Shift+at move container to workspace 2
        bindsym $mod+Shift+numbersign move container to workspace 3
        bindsym $mod+Shift+dollar move container to workspace 4
        bindsym $mod+Shift+percent move container to workspace 5
        bindsym $mod+Shift+asciicircum move container to workspace 6
        bindsym $mod+Shift+ampersand move container to workspace 7
        bindsym $mod+Shift+asterisk move container to workspace 8
        bindsym $mod+Shift+parenleft move container to workspace 9
        bindsym $mod+Shift+parenright move container to workspace 10      
        
        
        # resize window (you can also use the mouse for that)
        mode "resize" {
          # These bindings trigger as soon as you enter the resize mode

          # They resize the border in the direction you pressed, e.g.
          # when pressing left, the window is resized so that it has
          # more space on its left

          bindsym j resize shrink left 10 px or 10 ppt
          bindsym Shift+J resize grow   left 10 px or 10 ppt

          bindsym k resize shrink down 10 px or 10 ppt
          bindsym Shift+K resize grow   down 10 px or 10 ppt

          bindsym l resize shrink up 10 px or 10 ppt
          bindsym Shift+L resize grow   up 10 px or 10 ppt

          bindsym semicolon resize shrink right 10 px or 10 ppt
          bindsym Shift+colon resize grow   right 10 px or 10 ppt

          # same bindings, but for the arrow keys
          bindsym Left resize shrink left 10 px or 10 ppt
          bindsym Shift+Left resize grow   left 10 px or 10 ppt

          bindsym Down resize shrink down 10 px or 10 ppt
          bindsym Shift+Down resize grow   down 10 px or 10 ppt

          bindsym Up resize shrink up 10 px or 10 ppt
          bindsym Shift+Up resize grow   up 10 px or 10 ppt

          bindsym Right resize shrink right 10 px or 10 ppt
          bindsym Shift+Right resize grow   right 10 px or 10 ppt

          # back to normal: Enter or Escape
          bindsym Return mode "default"
          bindsym Escape mode "default"
        }

        bindsym $mod+r mode "resize"      
      '';

      checkI3Config =
        pkgs.runCommandLocal "i3-config" { buildInputs = [ package ]; } ''
          # We have to make sure the wrapper does not start a dbus session
          export DBUS_SESSION_BUS_ADDRESS=1
          # A zero exit code means i3 succesfully validated the configuration
          i3 -c ${configFile} -C -d all || {
            echo "i3 configuration validation failed"
            echo "For a verbose log of the failure, run 'i3 -c ${configFile} -C -d all'"
            exit 1
          };
          cp ${configFile} $out
        '';  
      in {
        source = checkI3Config;
        onChange = ''
          i3Socket=''${XDG_RUNTIME_DIR:-/run/user/$UID}/i3/ipc-socket.*
          if [ -S $i3Socket ]; then
            ${package}/bin/i3-msg -s $i3Socket reload >/dev/null
          fi    
        '';
    };
  };
}
