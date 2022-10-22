{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
	cfg = config.hardware;
in 
{  
	options.hardware = with types; {
		nvidia.enable = mkOpt bool false;
	};
	
	config = mkMerge [
		(mkIf cfg.nvidia.enable {
			services.xserver.videoDrivers = ["nvidia"];
		  hardware.opengl.enable = true;
		  hardware.nvidia.modesetting.enable = true;

		  environment.systemPackages = with pkgs; [  egl-wayland  ];
		})
	];
}

