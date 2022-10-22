{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
	targets = config.systemd.user.targets;
in 
{
	config = {
		
		systemd.user.services = listToAttrs (map (x: let
					name = removeSuffix ".service" x;
				in nameValuePair name {wantedBy = ["graphical-session.target"];}) 
			targets.graphical-session.wants);

	};
}
