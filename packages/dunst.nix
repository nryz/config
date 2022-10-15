{ pkgs, my, base16, font, ... }:

let
    configFile = with base16.withHashtag; ''
			[global]
			font="${font.name} ${toString font.size}"
			frame_color="${base09}"
			geometry="300x5-30+50"
			separator_color="${base09}"
			timeout=3
			transparency=0

			[urgency_critical]
			background="${base00}"
			foreground="${base05}"

			[urgency_low]
			background="${base00}"
			foreground="${base05}"

			[urgency_normal]
			background="${base00}"
			foreground="${base05}"
    '';
		
		serviceFile = ''
			[Service]
			BusName=org.freedesktop.Notifications
			Environment=
			ExecStart=${placeholder "out"}/bin/dunst
			Type=dbus

			[Unit]
			After=graphical-session-pre.target
			Description=Dunst notification daemon
			PartOf=graphical-session.target
		'';

in my.lib.wrapPackageJoin {
  pkg = pkgs.dunst;
  name = "dunst";

  outputs.service = {
    # "etc/systemd/user/dunst.service" = pkgs.writeText "dunst-service" serviceFile;
    "etc/systemd/user/dunst.service" = serviceFile;
  };

  flags = [ 
    "-config ${placeholder "out"}/config/dunstrc"
  ];

  files = {
    "config/dunstrc" = pkgs.writeText "dunstrc" configFile;
  };
}