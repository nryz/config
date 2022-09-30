{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.imv;
in
{
  options.blocks.programs.imv = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      imv
    ];

    xdg.configFile."imv/config".text = with config.scheme; ''
      [options]
      background = ${base00}
      loop_input = true
      overlay = true
      overlay_text = [$imv_current_index/$imv_file_count] $(basename $imv_current_file)
      overlay_text_color = ${base05}
      overlay_background_color = ${base00}
      overlay_position_bottom = true;
      suppress_default_binds = true;

      [aliases]
      # alias = command to run

      [binds]
      q = quit
      x = close

      # Image navigation
      h = prev
      l = next
      gg = goto 1
      <Shift+G> = goto -1

      # Panning
      <down> = pan 0 -50
      <up> = pan 0 50
      <left> = pan 50 0
      <right> = pan -50 0

      # Zooming
      k = zoom 1
      j = zoom -1

      # Rotate Clockwise by 90 degrees
      <Ctrl+r> = rotate by 90

      # Other commands
      f = fullscreen
      d = overlay
      p = exec echo $imv_current_file
      c = center
      s = scaling next
      <Shift+S> = upscaling next
      a = zoom actual
      r = reset

      # Gif playback
      <period> = next_frame
      <space> = toggle_playing

      # Slideshow control
      t = slideshow +1
      <Shift+T> = slideshow -1
    '';
  };
}
