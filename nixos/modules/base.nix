{ config, options, pkgs, lib, my, ... }:

with lib;
with my.lib;
let
  stateVersion = "21.11";
in
{
  options = with types; {
    bluetooth.enable = mkOpt bool false;
  };

  config = {
    system.stateVersion = stateVersion;

    nixpkgs.config = pkgs.config;
    nixpkgs.pkgs = pkgs;

    environment.systemPackages = with pkgs; [
      nix-prefetch-scripts
      nixos-option
      manix
      lshw
      usbutils
      xclip
      wget
      moreutils
      nix-tree
      networkmanager
      sshfs-fuse
      lftp
      ncftp
      inetutils
      pavucontrol
      pamixer
    ];

    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot.kernelParams = [ 
      "quiet"
      "splash"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "vt.global_cursor_default=0"
    ];

    boot.consoleLogLevel = 0;
    boot.initrd.verbose = false;
    boot.plymouth.enable = true;
    boot.plymouth.theme = "text";

    boot.loader.timeout = 1;
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 20;
      consoleMode = "auto";
      editor = false;
    };
    boot.loader.efi.canTouchEfiVariables = true;

    hardware.bluetooth.enable = config.bluetooth.enable;
    hardware.bluetooth.disabledPlugins = [ "sap" ];
    hardware.bluetooth.settings.General.Enable = "Source,Sink,Media,Socket";

    networking.hostName = my.hostName;
    networking.useDHCP = false;
    networking.interfaces.enp2s0.useDHCP = true;
    networking.networkmanager.enable = true;

    networking.nameservers = [
      "2a07:a8c0::df:f735"
      "2a07:a8c1::df:f735"
    ];

    programs.nm-applet.enable = true;
    programs.dconf.enable = true;

    services.fwupd.enable = true;
    services.tlp.enable = true;
    services.tlp.settings.USB_AUTOSUSPEND = 0;
    services.blueman.enable = config.bluetooth.enable;
    services.dbus.packages = optionals (config.bluetooth.enable) [ pkgs.blueman ];
    services.fstrim.enable = true;

    sound.enable = true;

    hardware.pulseaudio.enable = true;
    hardware.pulseaudio.extraConfig = ''
       load-module module-switch-on-connect
    '';
    hardware.enableAllFirmware = true;
    hardware.cpu.intel.updateMicrocode = true;

    fonts.enableDefaultFonts = true;
    fonts.fontDir.enable = true;
    fonts.fonts = with pkgs; [ (nerdfonts.override { fonts = [ "Iosevka" ];}) ];

    time.hardwareClockInLocalTime = true;

    # TODO: fix this
    # nscd fails due to start-limit-hit
    systemd.services.nscd.serviceConfig.StartLimitBurst = 20;
    systemd.enableEmergencyMode = false;

    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;

    users = {
      mutableUsers = false;
      users.nr = {
        extraGroups = [ "wheel" ];
        isNormalUser = true;
        passwordFile = "/etc/passwords/nr";
        uid = 1000;
      };

      users.root.hashedPassword = "!";
    };

    nix = {
      generateRegistryFromInputs = true;
      generateNixPathFromInputs = true;
      linkInputs = true;
    
      package = pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes
        warn-dirty = false
        allow-dirty = true
        keep-outputs = true
        keep-derivations = true
      '';

      gc = {
        automatic = true;
        options = "--delete-older-than 5d";
      };

      settings = {
        auto-optimise-store = true;
      };
    };

    assertions = [
      {
        assertion = lib.hasAttr "/etc/passwords" config.fileSystems;
        message = "no passwords dir in fileSystems";
      }
      {
        assertion = lib.hasAttr "/" config.fileSystems;
        message = "no root in fileSystems";
      }
      {
        assertion = lib.hasAttr "/nix" config.fileSystems;
        message = "no nix in fileSystems";
      }
      {
        assertion = lib.hasAttr "/boot" config.fileSystems;
        message = "no boot in fileSystems";
      }
    ];
  };
}
