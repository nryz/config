{ pkgs, my, inputs, ... }:

let
    configFile =  ''
      active-opacity = 1.0;
      backend = "glx";
      blur = false;
      blur-method = "dual_kawase";
      blur-strength = 8;
      corner-radius = 0;
      fade-delta = 10;
      fade-exclude = [  ];
      fade-in-step = 0.028;
      fade-out-step = 0.03;
      fading = false;
      inactive-opacity = 1.0;
      opacity-rule = [  ];
      shadow = false;
      shadow-exclude = [  ];
      shadow-offset-x = -15;
      shadow-offset-y = -15;
      shadow-opacity = 0.8;
      unredir-if-possible = true;
      vsync = true;
      wintypes: { dropdown_menu = { opacity = 1.0; }; popup_menu = { opacity = 1.0; }; };
      xinerama-shadow-crop = true;
    '';
  
    serviceFile = ''
      [Install]
      WantedBy=graphical-session.target

      [Service]
      ExecStart=${placeholder "out"}/bin/picom
      Restart=always
      RestartSec=3

      [Unit]
      Description=Picom X11 compositor
      PartOf=graphical-session.target
    '';
    
    # shellEscape = s: (replaceChars [ "\\" ] [ "\\\\" ] s);

in my.lib.wrapPackageJoin {
  pkg = pkgs.picom.overrideAttrs(_: { src = inputs.picom-ibhagwan; });

  name = "picom";
  
  outputs.service = {
    "etc/systemd/user/picom.service" = serviceFile;
  };

  flags = [ 
    "--config ${placeholder "out"}/config/picom.conf"
    "--experimental-backends"
  ];
  
  files = {
    "config/picom.conf" = pkgs.writeText "picom.conf" configFile;
  };
}
