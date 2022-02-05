{ config, lib, pkgs, inputs, blocks, ... }: 

{
  home.packages = with pkgs; [
    wally-cli
    qmk
    keymapviz
  ];

  system.udevPackages = with pkgs; [
    qmk-udev-rules
    (pkgs.writeTextFile {
      name = "vii_udev";
      text = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
      '';

      destination = "/etc/udev/rules.d/92-viia.rules";
    })
    (pkgs.writeTextFile {
      name = "wally_udev";
      text = ''
        # Teensy rules for the Ergodox EZ
        ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
        ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
        KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"
      '';

      destination = "/etc/udev/rules.d/50-wally.rules";
    })
  ];
}
