{ pkgs, my, base16, font, wrapPackage, ... }:

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

in wrapPackage {
  pkg = pkgs.unclutter;
  name = "unclutter";

  outputs.service = {
		files = {
	    "etc/systemd/user/unclutter.service" = serviceFile;
		};
  };

  flags = [ 
		"-idle 1"
		"-jitter 0"
  ];

}
