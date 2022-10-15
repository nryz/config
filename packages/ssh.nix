{ pkgs, my, base16, font, ... }:

let
	askPass = "${pkgs.ssh-askpass-fullscreen}/bin/ssh-askpass-fullscreen";
	
	pkg = pkgs.openssh;

	ak = my.lib.wrapPackageJoin {
	  pkg = pkgs.writeShellScriptBin "ak" ''
		  eval $(ssh-agent) >/dev/null
	    ${pkg}/bin/ssh-add -K
	    $@
	    eval $(${pkg}/bin/ssh-agent -k) >/dev/null
	  '';
		
		name = "ak";
		
		vars = {
			"SSH_ASKPASS" = "${askPass}";
		};
	};
	
	
	serviceFilepcsd = ''
		[Unit]
		Description=PC/SC Smart Card Daemon
		Requires=pcscd.socket
		Documentation=man:pcscd(8)

		[Service]
		ExecStart=${pkgs.pcscdlite}/sbin/pcscd --foreground --auto-exit $PCSCD_ARGS
		ExecReload=${pkgs.pcscdlite}/sbin/pcscd --hotplug
		EnvironmentFile=-/nix/store/yspplf2pm47kdln3xs7j2c2ls20akz0l-pcsclite-1.9.5/etc/default/pcscd

		[Install]
		Also=pcscd.socket
	'';

in my.lib.wrapPackageJoin {
	inherit pkg;
  name = "ssh";
	
	extraPkgs = [ ak ];
}
