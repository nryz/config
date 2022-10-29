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
    "config/gitui/custom.ron" = ''
      (
        selected_tab: Color::Reset,
  			command_fg: Color::White,
  			selection_bg: Color::Black,
  			selection_fg: Color::White,
  			cmdbar_bg: Color::Blue,
  			cmdbar_extra_lines_bg: Color::Blue,
  			disabled_fg: Color::DarkGray,
  			diff_line_add: Color::Green,
  			diff_line_delete: Color::Red,
  			diff_file_added: Color::LightGreen,
  			diff_file_removed: Color::LightRed,
  			diff_file_moved: Color::LightMagenta,
  			diff_file_modified: Color::Yellow,
  			commit_hash: Color::Magenta,
  			commit_time: Color::LightCyan,
  			commit_author: Color::Green,
  			danger_fg: Color::Red,
  			push_gauge_bg: Color::Blue,
  			push_gauge_fg: Color::Reset,
  			tag_fg: Color::LightMagenta,
  			branch_fg: Color::LightYellow,
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