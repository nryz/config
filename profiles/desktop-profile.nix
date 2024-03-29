{
  config,
  options,
  pkgs,
  lib,
  my,
  ...
}: {
  imports = [
    ./graphical-profile.nix
    ./core-profile.nix
  ];

  options = with lib.types; {
    profile.bluetooth.enable = lib.mkOption {
      type = bool;
      default = false;
    };
  };

  config = {
    xdg.mime.enable = true;

    environment.systemPackages = with pkgs; [
      xdg-utils
      lshw
      usbutils
      xclip
      wget
      moreutils
      nix-tree
      pavucontrol
      pamixer
      ncdu
    ];

    boot.loader.timeout = 1;
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 20;
      consoleMode = "auto";
      editor = false;
    };
    boot.loader.efi.canTouchEfiVariables = true;

    hardware.bluetooth.enable = config.profile.bluetooth.enable;
    hardware.bluetooth.disabledPlugins = ["sap"];
    hardware.bluetooth.settings.General.Enable = "Source,Sink,Media,Socket";

    programs.nm-applet.enable = true;
    programs.dconf.enable = true;

    services.fwupd.enable = true;
    services.tlp.enable = true;
    services.tlp.settings.USB_AUTOSUSPEND = 0;
    services.blueman.enable = config.profile.bluetooth.enable;
    services.dbus.packages = lib.optionals (config.profile.bluetooth.enable) [pkgs.blueman];
    services.fstrim.enable = true;

    sound.enable = true;

    hardware.pulseaudio.enable = true;
    hardware.pulseaudio.extraConfig = ''
      load-module module-switch-on-connect
    '';
    hardware.enableAllFirmware = true;
    hardware.cpu.intel.updateMicrocode = true;

    fonts.enableDefaultPackages = true;
    fonts.fontDir.enable = true;

    # TODO: fix this
    # nscd fails due to start-limit-hit
    systemd.services.nscd.serviceConfig.StartLimitBurst = 20;
    systemd.enableEmergencyMode = false;

    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;
  };
}
