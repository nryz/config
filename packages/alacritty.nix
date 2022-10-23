{ pkgs, my, base16, font, wrapPackage,  ... }:

let
  lib = pkgs.lib;
  
  configFile = with base16.withHashtag; ''
    window:
      opacity: 1.0
  
    font:
      normal:
        family: ${font.name}

      size: ${toString font.size}
    
    
    colors:
      primary:
        background: '${base00}'
        foreground: '${base05}' 
      
      normal:
        black:   '${base00}'
        red:     '${base08}'
        green:   '${base0B}'
        yellow:  '${base0A}'
        blue:    '${base0D}'
        magenta: '${base0E}'
        cyan:    '${base0C}'
        white:   '${base05}'

      bright:
        black:   '${base03}'
        red:     '${base08}'
        green:   '${base0B}'
        yellow:  '${base0A}'
        blue:    '${base0D}'
        magenta: '${base0E}'
        cyan:    '${base0C}'
        white:   '${base07}'
        
      indexed_colors:
        - { index: 16, color: '${base09}' }
        - { index: 17, color: '${base0F}' }
        - { index: 18, color: '${base01}' }
        - { index: 19, color: '${base02}' }
        - { index: 20, color: '${base04}' }
        - { index: 21, color: '${base06}' }
  '';

in wrapPackage {
  pkg = pkgs.alacritty;
  name = "alacritty";

  flags = [ 
    "--config-file ${placeholder "out"}/config/alacritty.yml"
  ];

  files = {
    "config/alacritty.yml" = configFile;
  };
}