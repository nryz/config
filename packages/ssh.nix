{ pkgs, my
, base16
, font
, wrapPackage
}:

let
	askPass = "${pkgs.ssh-askpass-fullscreen}/bin/ssh-askpass-fullscreen";
	
	pkg = pkgs.openssh;

	ak = wrapPackage {
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

in wrapPackage {
	inherit pkg;
  name = "ssh";
	
	extraPkgs = [ ak ];
}
