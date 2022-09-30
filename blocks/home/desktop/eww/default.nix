{ config, lib, pkgs, flakePath, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.desktop.eww;
  
  wmctrl = "${pkgs.wmctrl}/bin/wmctrl";
in
{
  options.blocks.desktop.eww = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; if config.blocks.desktop.wayland.enable then [
      eww-wayland
    ] else [
      eww
    ];
    
    xdg.configFile."eww/eww.scss".text = with config.scheme.withHashtag; ''
      * {
        all: unset; //Unsets everything so you can style everything from scratch
      }

      //Global Styles
      .bar {
        background-color: ${base00};
        color: ${base09};
        padding: 0px;
        border: 1px solid #000000;
      }
      
      .module {
        color: ${base09};
        padding-left: 10px;
        padding-right: 10px;
        font-size: 14px;
      }
      
      .label {
        color: ${base09};
        font-size: 22px;
      }
      
      .sep {
        color: ${base05}
      }

      .module button:hover {
        color: ${base09};
      }
    '';
    
    xdg.configFile."eww/eww.yuck".text = ''
      ;;Variables
      (defpoll time :interval "10s" "date '+%a %d %b, %H:%M'")
      (defpoll volume :interval "1s" "GetVolume")
      (defpoll network :interval "30s" "if [[ $(nmcli n) == \"enabled\" ]]; then echo 1; else echo 0; fi")
      
      (defvar calendar_dropdown false)

      (defwidget sep []
        (box :class "sep" :vexpand "false" :hexpand "false"
          (label :text "|")))
      
      (defwidget module [?label value]
        (box :class "module" :vexpand "false"
             :space-evenly true
             :hexpand "true"
             :spacing 2
            "''${label}  ''${value}" ))

      (defwidget module-sep-label [?label value]
        (box :class "module" :vexpand "false"
             :space-evenly true
             :hexpand "true"
             :spacing 2
              ( label :class "label" :text "''${label}")
            ( label :text "''${value}") ))
            
      (defwidget cpu []     (module-sep-label :label "" :value "''${round(EWW_CPU.avg, 0)}%" ))
      (defwidget mem []     (module-sep-label :label "" :value "''${round(EWW_RAM.used_mem_perc, 0)}%" ))
      (defwidget time []    (module :value {time} ))
      (defwidget volume []  (module-sep-label :label "" :value {volume} ))
      (defwidget network [] (module :label "network" :value {EWW_NET["enp2s0"].down} ))
    
          
      (defwidget workspaces []
        (box :class "module"
             :orientation "h"
             :space-evenly true
             :halign "start"
             :spacing 10
          (button :onclick "${wmctrl} -s 0" 1)
          (button :onclick "${wmctrl} -s 1" 2)
          (button :onclick "${wmctrl} -s 2" 3)
          (button :onclick "${wmctrl} -s 3" 4)
          (button :onclick "${wmctrl} -s 4" 5)
          (button :onclick "${wmctrl} -s 5" 6)
          (button :onclick "${wmctrl} -s 6" 7)
          (button :onclick "${wmctrl} -s 7" 8)
          (button :onclick "${wmctrl} -s 8" 9)))            
          
         
                
                
                
      (defwidget right []
          (box :orientation "h"
            :space-evenly false
          :halign "end"
      (volume)
      ;;(sep)
      ;;(network)
      (sep)
      (cpu)
      (sep)
      (mem)))
      
      (defwidget center []
        (box :orientation "h"
          :space-evenly false
        :halign "center"
      (time)))
      
      (defwidget left []
        (box :orientation "h"
          :space-evenly false
        :halign "start"
      (workspaces)))
      
     (defwidget bar []
        (centerbox :orientation "h"
          (left)
          (center)
          (right)))
      
     (defwindow bar
      :monitor 0
      :windowtype "dock"
      :geometry (geometry :x "0%"
                          :y "0%"
                          :width "100%"
                          :height "20px"
                          :anchor "top center")
      :reserve (struts :side "top" :distance "20px")
      (bar))           
    '';
  };
}
