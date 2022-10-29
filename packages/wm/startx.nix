{ pkgs,  my 
, cursor
, drivers ? {}
, tty ? 1
, font
}:

# mostly taken from: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/x11/xserver.nix
with pkgs.lib;
let

  driverNames = mapAttrsToList (n: v: n) drivers;

  fonts = [
    font.package
    pkgs.xorg.fontadobe100dpi
    pkgs.xorg.fontadobe75dpi
  ];
  
  modules = [
    pkgs.xorg.xorgserver.out
    pkgs.xorg.xf86inputevdev.out
  ] ++ (flatten (mapAttrsToList (n: v: v) drivers));
  
  xserver = my.lib.wrapPackage {
    pkg = pkgs.xorg.xorgserver;
    name = "X";
    
    extraPkgs = modules;
    path = modules;
    
    flags = [
      "-config ${placeholder "out"}/config/xorg.conf"
      "-xkbdir ${pkgs.xkeyboard_config}/etc/X11/xkb"
      ":0"
      "vt${toString tty}"
      "-verbose 3"
      "-nolisten tcp"
      "-terminate"
    ];
    
    files = {
      "config/xorg.conf" = pkgs.runCommand "xorg.conf" {
        preferLocalBuild = true;

        config = ''
          Section "ServerFlags"
            Option "AllowMouseOpenFail" "on"
            Option "DontZap" "on"
            Option "StandbyTime" "0"
            Option "SuspendTime" "0"
            Option "OffTime" "0"
            Option "BlankTime" "0"
          EndSection

          Section "Monitor"
            Identifier "Monitor[0]"
            Option "DPMS" "disable"
          EndSection


          Section "ServerLayout"
            Identifier "Layout[all]"
 
            # Reference the Screen sections for each driver.  This will
            # cause the X server to try each in turn.
            ${flip concatMapStrings driverNames (driver: ''
              Screen "Screen-${driver}[0]"
            '')}
          EndSection

          # For each supported driver, add a "Device" and "Screen"
          # section.
      
      
          ${flip concatMapStrings driverNames (driver: ''
            Section "Device"
              Identifier "Device-${driver}[0]"
              Driver "${driver}"
            EndSection

            Section "Screen"
              Identifier "Screen-${driver}[0]"
              Device "Device-${driver}[0]"
              Monitor "Monitor[0]"
              Option "RandRRotation" "on"
            EndSection
          '')}
      
          Section "InputClass"
            Identifier "Keyboard catchall"
            MatchIsKeyboard "on"
            Option "XkbModel" "pc104"
            Option "XkbLayout" "us"
            Option "XkbOptions" "eurosign:e"
            Option "XkbVariant" ""
          EndSection
      
          #
          # Catch-all evdev loader for udev-based systems
          # We don't simply match on any device since that also adds accelerometers
          # and other devices that we don't really want to use. The list below
          # matches everything but joysticks.

          Section "InputClass"
                  Identifier "evdev pointer catchall"
                  MatchIsPointer "on"
                  MatchDevicePath "/dev/input/event*"
                  Driver "evdev"
          EndSection

          Section "InputClass"
                  Identifier "evdev keyboard catchall"
                  MatchIsKeyboard "on"
                  MatchDevicePath "/dev/input/event*"
                  Driver "evdev"
          EndSection

          Section "InputClass"
                  Identifier "evdev touchpad catchall"
                  MatchIsTouchpad "on"
                  MatchDevicePath "/dev/input/event*"
                  Driver "evdev"
          EndSection

          Section "InputClass"
                  Identifier "evdev tablet catchall"
                  MatchIsTablet "on"
                  MatchDevicePath "/dev/input/event*"
                  Driver "evdev"
          EndSection

          Section "InputClass"
                  Identifier "evdev touchscreen catchall"
                  MatchIsTouchscreen "on"
                  MatchDevicePath "/dev/input/event*"
                  Driver "evdev"
          EndSection
      
        '';
      } ''
  
        echo 'Section "Files"' >> $out
    
        for i in ${toString fonts}; do
          if test "''${i:0:''${#NIX_STORE}}" == "$NIX_STORE"; then
            for j in $(find $i -name fonts.dir); do
              echo "  FontPath \"$(dirname $j)\"" >> $out
            done
          fi
        done

        for i in $(find ${toString modules} -type d); do
          if test $(echo $i/*.so* | wc -w) -ne 0; then
            echo "  ModulePath \"$i\"" >> $out
          fi
        done

        echo 'EndSection' >> $out
    
        echo >> $out
    
        echo "$config" >> $out
      '';
    };
  };
  

in my.lib.wrapPackage {
  pkg = pkgs.xorg.xinit;
  name = "startx";
  
  path = with pkgs.xorg; [
    xauth
    xinit
  ];
  
  appendFlags = [
    "--"
    "${placeholder "out"}/config/xserverrc"
  ];

  files = {
    "config/xinitrc" = let
       importedVariables = [
        "DBUS_SESSION_BUS_ADDRESS"
        "DISPLAY"
        "SSH_AUTH_SOCK"
        "XAUTHORITY"
        "XDG_DATA_DIRS"
        "XDG_RUNTIME_DIR"
        "XDG_SESSION_ID"
      ];
    in ''
      systemctl --user import-environment ${toString (unique importedVariables)} &
      systemctl --user start graphical-session.target &

      export XDG_SESSION_TYPE=x11

      ${pkgs.xorg.xrdb}/bin/xrdb -merge ${placeholder "out"}/config/xresources
    '';

    "config/xresources" = ''
      Xcursor.size: ${toString cursor.size}
      Xcursor.theme: ${cursor.name}
    '';

    "config/xserverrc" = ''
      exec ${xserver}/bin/X
    '';
  };
}
