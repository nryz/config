{ pkgs, my, base16, font, ... }:

let
    # TODO:
    # ''
    # #!/usr/bin/env bash

    # arg="$*"

    # list_entry() {
    #   if [[ -z "$arg" ]]; then
    #     echo "$1"
    #   elif [ "$arg" = "$1" ]; then
    #     $2
    #     exit 0
    #   fi
    # }

    # list() {
    #   for tag in $(herbstclient complete 1 move); do
    #   list_entry "Move window to tag $tag" "herbstclient move $tag"
    # done

  
    #   list_entry 'floating' 'herbstclient set_attr clients.focus.floating toggle'
    # list_entry 'fullscreen' 'herbstclient fullscreen toggle'
    # }

    # list
    # '';
    
    
    # ''
    #   for tag in $(/nix/store/cp8i6lhxkgccgm37x0jzi5gf02dlqqq8-herbstluftwm-0.9.5/bin/herbstclient complete 1 use); do
    #     list_entry "Go to tag $tag" "/nix/store/cp8i6lhxkgccgm37x0jzi5gf02dlqqq8-herbstluftwm-0.9.5/bin/herbstclient use $tag"
    #   done
    # '';
    
    
    
    
    configFile = ''
        configuration {
        	modes: [drun,run,window,keys];
        }
        
        @theme "custom"
    '';

    themeFile = with base16.withHashtag; ''
       * {
        font: "${font.name + " " + toString font.size}";
       }
      
       window {
          padding: 0;
          border-color: black;
          background-color: ${base00};
          border: 0;
          fullscreen: false;
        }
        
        mainbox {
          children: [ inputbar, listview-box];
          background-color: ${base00};
          pading: 0;
          spacing: 0;
          border: 0;
        }
        
        listview-box {
          border: 0px 1px 1px 1px;
          padding: 1px 1px 1px 1px;
          border-color: black;
          background-color: ${base09};
          children: [ listview ];
        }

        listview {
          columns: 1;
          dynamic: false;
          padding: 2px 0px 0px;
          scrollbar: false;
          border-color: black;
          background-color: ${base00};
          spacing: 2px;
          fixed-height: 0;
          border: 1;
        }

        element {
          padding: 4px;
          cursor: pointer;
          orientation: horizontal;
          children: [ element-icon, element-text];
          background-color: ${base00};
          spacing: 5px;
          border: 0;
        }
        
        element-text {
          text-color: ${base05};
          background-color: inherit;
        }
        
        element-icon {
          background-color: inherit;
        }
        
               
        element selected {
          background-color: ${base01};
        }
                      
        
        inputbar {
          background-color: ${base00};
          border: 0px;
          border-color: black;
          padding: 0px;
          spacing: 0px;
          text-color: ${base05};
          children: [ "prompt", "entry-bar" ];
        }
        
        entry-bar {
          orientation: horizontal;
          background-color: inherit;
          text-color: ${base09};
          border: 1px;
          border-color: black;
          spacing: 0px;
          padding: 3px;
          children: [ "dummy-entry", "entry", "dummy-entry", "num-filtered-rows", "textbox-num-sep", "num-rows", "case-indicator"];
        }
        
        case-indicator {
          background-color: inherit;
          text-color: inherit;
        }
        
        prompt {
          border: 1px 0px 0px 1px;
          border-color: black;
          padding: 3px 10px 3px 10px;
          spacing: 0px;
          background-color: ${base09};
          text-color: ${base00};
        }
        
        num-rows {
          expand: false;
          background-color: inherit;
          text-color: inherit;
        }
        
        num-filtered-rows {
          expand: false;
          background-color: inherit;
          text-color: inherit;
        }
        
        textbox-num-sep {
          expand: false;
          background-color: inherit;
          str: "/";
          text-color: inherit;
        }
        
        textbox-prompt-colon {
          background-color: inherit;
          margin: 0px 0.3000em 0.0000em 0.000em;
          expand: false;
          str: ":";
          text-color: inherit;
        }
        
        dummy-entry {
          background-color: inherit;
          expand: true;
        }
                    
        entry {
          spacing: 0;
          expand: false;
          cursor: text;
          placeholder-color: ${base04};
          placeholder: "type here";
          text-color: ${base05};
          background-color: ${base00};
        }      
    '';

in my.lib.wrapPackageJoin {
  pkg = pkgs.rofi;
  name = "rofi";

  vars = { 
    "XDG_CONFIG_HOME" = "${placeholder "out"}/config";
  };

  files = {
    "config/rofi/config.rasi" = pkgs.writeText "config.rasi" configFile;
    "config/rofi/custom.rasi" = pkgs.writeText "config.rasi" themeFile;
  };
}
