{ pkgs, my, base16, font, ... }:

let
		serviceFile = ''
			[Install]
			WantedBy=graphical-session.target

			[Service]
			ExecStart=${placeholder "out"}/bin/unclutter
			Restart=always
			RestartSec=3

			[Unit]
			After=graphical-session-pre.target
			Description=unclutter
			PartOf=graphical-session.target
		'';

in my.lib.wrapPackageJoin {
  pkg = pkgs.unclutter;
  name = "unclutter";

  outputs.service = {
    "etc/systemd/user/unclutter.service" = serviceFile;
  };

  flags = [ 
		"--timeout 1"
		"--jitter 0"
  ];

}
