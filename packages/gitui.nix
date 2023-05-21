{ inputs, pkgs, my
, wrapPackage
, base16
}:

let
  lib = pkgs.lib;
  
in wrapPackage {
  pkg = pkgs.gitui;
  name = "gitui";
  
  alias = "gu";
  
  vars = {
    "XDG_CONFIG_HOME" = "${placeholder "out"}/config";
  };
  
  flags = [
    "-t custom.ron"
  ];

  files = {
    "config/gitui/theme.ron" = with base16; let
      mkRgb = n: let b = base16; in
        "Rgb(${b."base${n}-rgb-r"},${b."base${n}-rgb-g"},${b."base${n}-rgb-b"})";
    in ''
      (
        selected_tab: ${mkRgb "09"},
  			command_fg: ${mkRgb "05"},
  			selection_bg: ${mkRgb "01"},
  			selection_fg: ${mkRgb "05"},
  			cmdbar_bg: ${mkRgb "00"},
  			cmdbar_extra_lines_bg: ${mkRgb "01"},
  			disabled_fg: ${mkRgb "02"},
  			diff_line_add: Rgb(0,255,0),
  			diff_line_delete: Rgb(255,0,0),
  			diff_file_added: Rgb(0,128,0),
  			diff_file_removed: Rgb(128,0,0),
  			diff_file_moved: LightMagenta,
  			diff_file_modified: Yellow,
  			commit_hash: Magenta,
  			commit_time: LightCyan,
  			commit_author: Green,
  			danger_fg: Red,
  			push_gauge_bg: Blue,
  			push_gauge_fg: Reset,
  			tag_fg: LightMagenta,
  			branch_fg: LightYellow,
      )
    '';
    
    "config/gitui/key_bindings.ron" = ''
      (
          focus_right: Some(( code: Char('l'), modifiers: ( bits: 0,),)),
          focus_left: Some(( code: Char('h'), modifiers: ( bits: 0,),)),
          focus_above: Some(( code: Char('k'), modifiers: ( bits: 0,),)),
          focus_below: Some(( code: Char('j'), modifiers: ( bits: 0,),)),

          open_help: Some(( code: Char('?'), modifiers: ( bits: 0,),)),

          move_left: Some(( code: Char('h'), modifiers: ( bits: 0,),)),
          move_right: Some(( code: Char('l'), modifiers: ( bits: 0,),)),
          move_up: Some(( code: Char('k'), modifiers: ( bits: 0,),)),
          move_down: Some(( code: Char('j'), modifiers: ( bits: 0,),)),

          popup_up: Some(( code: Char('p'), modifiers: ( bits: 2,),)),
          popup_down: Some(( code: Char('n'), modifiers: ( bits: 2,),)),

          page_up: Some(( code: Char('b'), modifiers: ( bits: 2,),)),
          page_down: Some(( code: Char('f'), modifiers: ( bits: 2,),)),

          home: Some(( code: Char('g'), modifiers: ( bits: 0,),)),
          end: Some(( code: Char('G'), modifiers: ( bits: 1,),)),

          shift_up: Some(( code: Char('K'), modifiers: ( bits: 1,),)),
          shift_down: Some(( code: Char('J'), modifiers: ( bits: 1,),)),

          edit_file: Some(( code: Char('I'), modifiers: ( bits: 1,),)),

          status_reset_item: Some(( code: Char('U'), modifiers: ( bits: 1,),)),

          diff_reset_lines: Some(( code: Char('u'), modifiers: ( bits: 0,),)),
          diff_stage_lines: Some(( code: Char('s'), modifiers: ( bits: 0,),)),

          stashing_save: Some(( code: Char('w'), modifiers: ( bits: 0,),)),
          stashing_toggle_index: Some(( code: Char('m'), modifiers: ( bits: 0,),)),

          stash_open: Some(( code: Char('l'), modifiers: ( bits: 0,),)),

          abort_merge: Some(( code: Char('M'), modifiers: ( bits: 1,),)),
      )
    '';
  };
}