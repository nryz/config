{ pkgs
, my
, wrapPackage
, base16
}:

wrapPackage {
  pkg = pkgs.bottom;
  name = "btm";
  
  flags = [
    "--config ${placeholder "out"}/config/bottom.toml"
  ];

  files = {
    "config/bottom.toml" = with base16.withHashtag; ''
      [colors]
      widget_title_color="${base05}"
      border_color="${base01}"
      highlighted_border_color="${base09}"
      text_color="${base05}"
      selected_text_color="${base00}"
      selected_bg_color="${base09}"
      table_header_color="${base0D}"
      
      # Layout
      [[row]]
        ratio=30
        [[row.child]]
          ratio=2
          type="cpu"
        [[row.child]]
          type="mem"
      [[row]]
        ratio=30
        [[row.child]]
          type="disk"
        [[row.child]]
          type="temp"
        [[row.child]]
            type="net"
      [[row]]
        ratio=40
        [[row.child]]
          type="proc"
          default=true
          
      [mount_filter]
      is_list_ignored = true
      regex = true
      list = ["[^/nix|/boot]"]
    '';
  };
}
