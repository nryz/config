{ inputs, pkgs, my, wrapPackage, base16
, naersk
, editor
, ... }:

let
  lib = pkgs.lib;
  
  configFile = ''
    # Configurations related to the display
    [display]
    # Different view layouts
    # Options include
    # - default
    # - hsplit
    mode = "default"

    # Ratios for parent view, current view and preview. You can specify 0 for
    # parent view or omit it (So there are only 2 nums) and it won't be displayed
    column_ratio = [1, 3, 4]

    # Options include
    # - none
    # - absolute
    # - relative
    line_number_style = "relative"

    # Configurations related to file sorting
    [display.sort]
    # Options include
    # - lexical  (10.txt comes before 2.txt)
    # - natural  (2.txt comes before 10.txt)
    # - mtime
    method = "natural"

    show_borders = true
    show_hidden = true
    show_icons = true
    tilde_in_titlebar = true
    case_sensitive = false
    directories_first = true
    reverse = false
    collapse_preview = false
  '';
  
  keymapFile = ''
    [default_view]

    keymap = [
    	{ keys = [ "escape" ],		command = "escape" },
    	{ keys = [ "T" ],		      command = "new_tab" },
    	{ keys = [ "ctrl+t" ],		command = "new_tab" },
    	{ keys = [ "W" ],		      command = "close_tab" },
    	{ keys = [ "ctrl+w" ],		command = "close_tab" },
    	{ keys = [ "q" ],		      command = "close_tab" },
    	{ keys = [ "Q" ],		      command = "quit --output-current-directory" },

    	{ keys = [ "R" ],		      command = "reload_dirlist" },
    	{ keys = [ "z", "h" ],		command = "toggle_hidden" },
    	{ keys = [ "ctrl+h" ],		command = "toggle_hidden" },
    	{ keys = [ "\t" ],		    command = "tab_switch 1" },
    	{ keys = [ "backtab" ],		command = "tab_switch -1" },

    	{ keys = [ "alt+1" ],		command = "tab_switch_index 1" },
    	{ keys = [ "alt+2" ],		command = "tab_switch_index 2" },
    	{ keys = [ "alt+3" ],		command = "tab_switch_index 3" },
    	{ keys = [ "alt+4" ],		command = "tab_switch_index 4" },
    	{ keys = [ "alt+5" ],		command = "tab_switch_index 5" },

    	{ keys = [ "1" ],		command = "numbered_command 1" },
    	{ keys = [ "2" ],		command = "numbered_command 2" },
    	{ keys = [ "3" ],		command = "numbered_command 3" },
    	{ keys = [ "4" ],		command = "numbered_command 4" },
    	{ keys = [ "5" ],		command = "numbered_command 5" },
    	{ keys = [ "6" ],		command = "numbered_command 6" },
    	{ keys = [ "7" ],		command = "numbered_command 7" },
    	{ keys = [ "8" ],		command = "numbered_command 8" },
    	{ keys = [ "9" ],		command = "numbered_command 9" },

    	# arrow keys
    	{ keys = [ "arrow_up" ],	  command = "cursor_move_up" },
    	{ keys = [ "arrow_down" ],	command = "cursor_move_down" },
    	{ keys = [ "arrow_left" ],	command = "cd .." },
    	{ keys = [ "arrow_right" ],	command = "open" },
    	{ keys = [ "\n" ],		      command = "open" },
    	{ keys = [ "home" ],		    command = "cursor_move_home" },
    	{ keys = [ "end" ],		      command = "cursor_move_end" },
    	{ keys = [ "page_up" ],		  command = "cursor_move_page_up" },
    	{ keys = [ "page_down" ],	  command = "cursor_move_page_down" },
    	{ keys = [ "ctrl+u" ],  	  command = "cursor_move_page_up 0.5" },
    	{ keys = [ "ctrl+d" ], 		  command = "cursor_move_page_down 0.5" },

    	# vim-like keybindings
    	{ keys = [ "j" ],		      command = "cursor_move_down" },
    	{ keys = [ "k" ],		      command = "cursor_move_up" },
    	{ keys = [ "h" ],		      command = "cd .." },
    	{ keys = [ "l" ],		      command = "open" },
    	{ keys = [ "g", "g" ],		command = "cursor_move_home" },
    	{ keys = [ "G" ],		      command = "cursor_move_end" },
    	{ keys = [ "r" ],		      command = "open_with" },

    	{ keys = [ "H" ],		command = "cursor_move_page_home" },
    	{ keys = [ "L" ],		command = "cursor_move_page_middle" },
    	{ keys = [ "M" ],		command = "cursor_move_page_end" },

    	{ keys = [ "[" ],		command = "parent_cursor_move_up" },
    	{ keys = [ "]" ],		command = "parent_cursor_move_down" },

    	{ keys = [ "c", "d" ],		command = ":cd " },
    	{ keys = [ "d", "d" ],		command = "cut_files" },
    	{ keys = [ "y", "y" ],		command = "copy_files" },
    	{ keys = [ "y", "n" ],		command = "copy_filename" },
    	{ keys = [ "y", "." ],		command = "copy_filename_without_extension" },
    	{ keys = [ "y", "p" ],		command = "copy_filepath" },
    	{ keys = [ "y", "d" ],		command = "copy_dirpath" },

    	{ keys = [ "p", "l" ],		command = "symlink_files --relative=false" },
    	{ keys = [ "p", "L" ],		command = "symlink_files --relative=true" },

    	{ keys = [ "delete" ],		command = "delete_files --foreground=true" },
    	{ keys = [ "d", "D" ],		command = "delete_files --foreground=true" },

    	{ keys = [ "p", "p" ],		command = "paste_files" },
    	{ keys = [ "p", "o" ],		command = "paste_files --overwrite=true" },

    	{ keys = [ "a" ],		command = "rename_append" },
    	{ keys = [ "A" ],		command = "rename_prepend" },

    	{ keys = [ "f", "t" ],		command = ":touch " },

    	{ keys = [ " " ],		command = "select --toggle=true" },
    	{ keys = [ "t" ],		command = "select --all=true --toggle=true" },
    	{ keys = [ "V" ],		command = "toggle_visual"},

    	{ keys = [ "w" ],		      command = "show_tasks --exit-key=w" },
    	{ keys = [ "b", "b" ],		command = "bulk_rename" },
    	{ keys = [ "=" ],		      command = "set_mode" },

    	{ keys = [ ":" ],		command = ":" },
    	{ keys = [ ";" ],		command = ":" },

    	{ keys = [ "'" ],		      command = ":shell " },
    	{ keys = [ "m", "k" ],		command = ":mkdir " },
    	{ keys = [ "c", "w" ],		command = ":rename " },

    	{ keys = [ "/" ],		command = ":search " },
    	{ keys = [ "|" ],		command = ":search_inc " },
    	{ keys = [ "\\" ],	command = ":search_glob " },
    	{ keys = [ "S" ],		command = "search_fzf" },
    	{ keys = [ "C" ],		command = "subdir_fzf" },

    	{ keys = [ "n" ],		command = "search_next" },
    	{ keys = [ "N" ],		command = "search_prev" },

    	{ keys = [ "s", "r" ],		command = "sort reverse" },
    	{ keys = [ "s", "l" ],		command = "sort lexical" },
    	{ keys = [ "s", "m" ],		command = "sort mtime" },
    	{ keys = [ "s", "n" ],		command = "sort natural" },
    	{ keys = [ "s", "s" ],		command = "sort size" },
    	{ keys = [ "s", "e" ],		command = "sort ext" },

    	{ keys = [ "m", "s" ],		command = "linemode size" },
    	{ keys = [ "m", "m" ],		command = "linemode mtime" },
    	{ keys = [ "m", "M" ],		command = "linemode sizemtime" },

    	{ keys = [ "g", "r" ],		command = "cd /" },
    	{ keys = [ "g", "h" ],		command = "cd ~/" },
    	{ keys = [ "?" ],		      command = "help" }
    ]

    [task_view]

    keymap = [
    	# arrow keys
    	{ keys = [ "arrow_up" ],	command = "cursor_move_up" },
    	{ keys = [ "arrow_down" ],	command = "cursor_move_down" },
    	{ keys = [ "home" ],		command = "cursor_move_home" },
    	{ keys = [ "end" ],		command = "cursor_move_end" },

    	# vim-like keybindings
    	{ keys = [ "j" ],		command = "cursor_move_down" },
    	{ keys = [ "k" ],		command = "cursor_move_up" },
    	{ keys = [ "g", "g" ],		command = "cursor_move_home" },
    	{ keys = [ "G" ],		command = "cursor_move_end" },

    	{ keys = [ "w" ],		command = "show_tasks" },
    	{ keys = [ "escape" ],		command = "show_tasks" },
    ]

    [help_view]

    keymap = [
    	# arrow keys
    	{ keys = [ "arrow_up" ],	command = "cursor_move_up" },
    	{ keys = [ "arrow_down" ],	command = "cursor_move_down" },
    	{ keys = [ "home" ],		command = "cursor_move_home" },
    	{ keys = [ "end" ],		command = "cursor_move_end" },

    	# vim-like keybindings
    	{ keys = [ "j" ],		command = "cursor_move_down" },
    	{ keys = [ "k" ],		command = "cursor_move_up" },
    	{ keys = [ "g", "g" ],		command = "cursor_move_home" },
    	{ keys = [ "G" ],		command = "cursor_move_end" },

    	{ keys = [ "w" ],		command = "show_tasks" },
    	{ keys = [ "escape" ],		command = "show_tasks" },
    ]
  '';
  
  themeFile = with base16.withHashtag; ''
    [selection]
    fg = "${base02}"
    bold = true

    [visual_mode_selection]
    fg = "${base03}"
    bold = true

    [selection.prefix]
    prefix = "  "
    size = 2

    [executable]
    fg = "${base0B}"
    bold = true

    [regular]
    fg = "${base05}"

    [directory]
    fg = "${base0C}"
    bold = true

    [link]
    fg = "${base08}"
    bold = true

    [link_invalid]
    fg = "${base0F}"
    bold = true

    [socket]
    fg = "${base0A}"
    bold = true

    [ext]

    bmp.fg	= "${base09}"
    gif.fg	= "${base09}"
    heic.fg	= "${base09}"
    jpg.fg	= "${base09}"
    jpeg.fg	= "${base09}"
    pgm.fg	= "${base09}"
    png.fg	= "${base09}"
    ppm.fg	= "${base09}"
    svg.fg	= "${base09}"

    wav.fg	= "${base0D}"
    flac.fg = "${base0D}"
    mp3.fg	= "${base0D}"
    amr.fg	= "${base0D}"

    avi.fg	= "${base0E}"
    flv.fg	= "${base0E}"
    m3u.fg	= "${base0E}"
    m4a.fg	= "${base0E}"
    m4v.fg	= "${base0E}"
    mkv.fg	= "${base0E}"
    mov.fg	= "${base0E}"
    mp4.fg	= "${base0E}"
    mpg.fg	= "${base0E}"
    rmvb.fg	= "${base0E}"
    webm.fg	= "${base0E}"
    wmv.fg	= "${base0E}"
  '';
  
  imageViewScript = ''
    #!/usr/bin/env bash
    ${my.pkgs.imv}/bin/imv . -n $1
  '';
  
  mimetypeFile = ''
    [class]
    image_default = [ { command = "${placeholder "out"}/scripts/image-view", fork = true, silent = true } ]
    video_default = [ { command = "${my.pkgs.mpv}/bin/mpv", fork = true, silent = true } ]
    audio_default = [ { command = "mpv", args = [ "--" ] } ]
    text_default = [ { command = "${editor.bin}" } ]
    reader_default = [ { command = "${my.pkgs.zathura}/bin/zathura", fork = true, silent = true } ]

    [extension]
    ## text formats
    build.inherit	=   "text_default"
    c.inherit	=       "text_default"
    cmake.inherit	=   "text_default"
    conf.inherit	=   "text_default"
    cpp.inherit	=     "text_default"
    css.inherit	=     "text_default"
    csv.inherit	=     "text_default"
    cu.inherit	=     "text_default"
    ebuild.inherit =  "text_default"
    eex.inherit	=     "text_default"
    env.inherit	=     "text_default"
    ex.inherit	=     "text_default"
    exs.inherit	=     "text_default"
    go.inherit	=     "text_default"
    h.inherit	=       "text_default"
    hpp.inherit	=     "text_default"
    hs.inherit	=     "text_default"
    html.inherit =    "text_default"
    ini.inherit	=     "text_default"
    java.inherit =    "text_default"
    js.inherit	=     "text_default"
    json.inherit =    "text_default"
    kt.inherit	=     "text_default"
    lua.inherit	=     "text_default"
    log.inherit	=     "text_default"
    md.inherit	=     "text_default"
    micro.inherit	=   "text_default"
    ninja.inherit	=   "text_default"
    nix.inherit =     "text_default"
    py.inherit	=     "text_default"
    rkt.inherit	=     "text_default"
    rs.inherit	=     "text_default"
    scss.inherit =    "text_default"
    sh.inherit	=     "text_default"
    srt.inherit	=     "text_default"
    svelte.inherit =  "text_default"
    toml.inherit =    "text_default"
    tsx.inherit	=     "text_default"
    txt.inherit	=     "text_default"
    vim.inherit	=     "text_default"
    xml.inherit	=     "text_default"
    yaml.inherit =    "text_default"
    yml.inherit	=     "text_default"   
    
    pdf.inherit	= "reader_default"
    
    ## image formats
    avif.inherit =  "image_default"
    bmp.inherit	=   "image_default"
    gif.inherit	=   "image_default"
    heic.inherit =  "image_default"
    jpeg.inherit =  "image_default"
    jpe.inherit	=   "image_default"
    jpg.inherit	=   "image_default"
    pgm.inherit	=   "image_default"
    png.inherit	=   "image_default"
    ppm.inherit	=   "image_default"
    webp.inherit =  "image_default"

    ## audio formats
    flac.inherit =  "audio_default"
    m4a.inherit	=   "audio_default"
    mp3.inherit	=   "audio_default"
    ogg.inherit	=   "audio_default"
    wav.inherit	=   "audio_default"

    ## video formats
    avi.inherit	=   "video_default"
    av1.inherit	=   "video_default"
    flv.inherit	=   "video_default"
    mkv.inherit	=   "video_default"
    m4v.inherit	=   "video_default"
    mov.inherit	=   "video_default"
    mp4.inherit	=   "video_default"
    ts.inherit	=   "video_default"
    webm.inherit =  "video_default"
    wmv.inherit	=   "video_default"
    
    [mimetype]

    [mimetype.application.subtype.octet-stream]
    inherit = "video_default"
    
    [mimetype.image]
    inherit = "image_default"

    [mimetype.text]
    inherit = "text_default"

    [mimetype.video]
    inherit = "video_default"
  '';

in wrapPackage {
  pkg = naersk.buildPackage inputs.joshuto;
  name = "joshuto";
  
  alias = "js";
  
  path = with pkgs; [
    file
  ];
  
  vars = {
    "JOSHUTO_CONFIG_HOME" = "${placeholder "out"}/config";
  };

  files = {
    "config/joshuto.toml" = configFile;
    "config/keymap.toml" = keymapFile;
    "config/mimetype.toml" = mimetypeFile;
    "config/theme.toml" = themeFile;
  };
  
  scripts = {
    "scripts/image-view" = imageViewScript;
  };
}