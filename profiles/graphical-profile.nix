{ config, options, pkgs, lib, my, ... }:

{
  options = with lib.types; {
    profile.nvidia.enable = lib.mkOption {
			type = bool;
			default = false;
		};
  };

	config = lib.mkMerge [
		(lib.mkIf config.profile.nvidia.enable {
			services.xserver.videoDrivers = ["nvidia"];
		  hardware.opengl.enable = true;
		  hardware.nvidia.modesetting.enable = true;

		  environment.systemPackages = with pkgs; [  egl-wayland  ];
		})
	];
}
