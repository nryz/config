{ config, lib, pkgs, ...}:

{
  xsession = {
    enable = true;

    scriptPath = ".xsession";

    pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      defaultCursor = "left_ptr";
      size = 24;
    };
  };
}
