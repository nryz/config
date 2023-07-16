use flake.nu *

let-env config = {
  show_banner: false
  ls: {
    use_ls_colors: true
    clickable_links: true
  }
  rm: {
    always_trash: false
  }
  cd: {
    abbreviations: false
  }
  table: {
    mode: heavy
    index_mode: always
    show_empty: true
    trim: {
      methodology: wrapping
      wrapping_try_keep_words: true
      truncating_suffix: "..."
    }
  }

  explore: {
    help_banner: true
    exit_esc: true

    command_bar_text: '#C4C9C6'
    # command_bar: {fg: '#C4C9C6' bg: '#223311' }

    status_bar_background: {fg: '#1D1F21' bg: '#C4C9C6' }
    # status_bar_text: {fg: '#C4C9C6' bg: '#223311' }

    highlight: {bg: 'yellow' fg: 'black' }

    status: {
      # warn: {bg: 'yellow', fg: 'blue'}
      # error: {bg: 'yellow', fg: 'blue'}
      # info: {bg: 'yellow', fg: 'blue'}
    }

    try: {
      # border_color: 'red'
      # highlighted_color: 'blue'

      # reactive: false
    }

    table: {
      split_line: '#404040'

      cursor: true

      line_index: true
      line_shift: true
      line_head_top: true
      line_head_bottom: true

      show_head: true
      show_index: true

      # selected_cell: {fg: 'white', bg: '#777777'}
      # selected_row: {fg: 'yellow', bg: '#C1C2A3'}
      # selected_column: blue

      # padding_column_right: 2
      # padding_column_left: 2

      # padding_index_left: 2
      # padding_index_right: 1
    }

    config: {
      cursor_color: {bg: 'yellow' fg: 'black' }

      # border_color: white
      # list_color: green
    }
  }

  history: {
    max_size: 10000
    sync_on_enter: true
    file_format: "plaintext"
    history_isolation: true
  }

  completions: {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "fuzzy"
    external: {
      enable: true
      max_results: 100
      completer: {|spans|
        ^$carapace $spans.0 nushell $spans | from json
      }
    }
  }

  filesize: {
    metric: true
    format: "auto"
  }

  cursor_shape: {
    emacs: line
    vi_insert: line
    vi_normal: block
  }

  color_config: {
    background: $base16.base00
    foreground: $base16.base05
    cursor: $base16.base05

    separator: $base16.base03
    leading_trailing_space_bg: { attr: "n" }
    header: { fg: $base16.base0B attr: "b" }
    empty: $base16.base0D
    bool: {|| if $in { $base16.base0C } else { "light_gray" } }
    int: $base16.base0B

    filesize: {|e|
        if $e == 0b {
          $base16.base05
        } else if $e < 1mb {
          $base16.base0C
        } else {{ fg: $base16.base0D }}
    }

    duration: $base16.base08

    date: {|| (date now) - $in |
       if $in < 1hr {
        { fg: $base16.base08 attr: "b" }
      } else if $in < 6hr {
        $base16.base08
      } else if $in < 1day {
        $base16.base0A
      } else if $in < 3day {
        $base16.base0B
      } else if $in < 1wk {
        { fg: $base16.base0B attr: "b" }
      } else if $in < 6wk {
        $base16.base0C
      } else if $in < 52wk {
        $base16.base0D
      } else { "dark_gray" }
    }

    range: $base16.base08
    float: $base16.base08
    string: $base16.base04
    nothing: $base16.base08
    binary: $base16.base08
    cellpath: $base16.base08
    row_index: $base16.base0C
    record: $base16.base05
    list: $base16.base05
    block: $base16.base05
    hints: dark_gray
    search_result: { fg: $base16.base08 bg: $base16.base05 }

    shape_and: $base16.base0E
    shape_binary: $base16.base0E
    shape_block: $base16.base0D
    shape_bool: $base16.base0D
    shape_custom: {attr: "b"}
    shape_datetime: $base16.base0C
    shape_directory: $base16.base0C
    shape_external: $base16.base0C
    shape_externalarg: { fg: $base16.base0B attr: "b"}
    shape_filepath: $base16.base0D
    shape_flag: { fg: $base16.base0D attr: "b"}
    shape_float: { fg: $base16.base0E attr: "b"}
    shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: "b"}
    shape_globpattern: { fg: $base16.base0D attr: "b"}
    shape_int: { fg: $base16.base0E attr: "b"}
    shape_internalcall: { fg: $base16.base0C attr: "b"}
    shape_list: $base16.base0C
    shape_literal: $base16.base0D
    shape_match_pattern: $base16.base0B
    shape_matching_brackets: { attr: "u" }
    shape_nothing: $base16.base0C
    shape_operator: $base16.base0A
    shape_or: { fg: $base16.base0E attr: "b"}
    shape_pipe: { fg: $base16.base0E attr: "b"}
    shape_range: { fg: $base16.base0A attr: "b"}
    shape_record: { fg: $base16.base0C attr: "b"}
    shape_redirection: { fg: $base16.base0E attr: "b"}
    shape_signature: { fg: $base16.base0B attr: "b"}
    shape_string: $base16.base0B
    shape_string_interpolation: { fg: $base16.base0C attr: "b" }
    shape_table: { fg: $base16.base0D attr: "b" }
    shape_variable: $base16.base0E
  }

  use_grid_icons: true
  footer_mode: "25"
  float_precision: 2
  use_ansi_coloring: true
  bracketed_paste: true
  edit_mode: vi
  shell_integration: true
  render_right_prompt_on_last_line: false

  hooks: {
    pre_prompt: [{||
      null
      #print pre_prompt # replace with source code to run before the prompt is shown
    }]
    pre_execution: [{||
      null  # replace with source code to run before the repl input is run
    }]
    env_change: {
      PWD: [{|before, after|
        null # replace with source code to run if the PWD environment is different since the last repl input
      }]
    }
    display_output: {||
      if (term size).columns >= 100 { table -e } else { table }
    }
    command_not_found: {||
      null  # replace with source code to return an error message when a command is not found
    }
  }
  menus: [
      {
        name: completion_menu
        only_buffer_difference: false
        marker: "| "
        type: {
            layout: columnar
            columns: 4
            col_width: 20
            col_padding: 2
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
      }
      {
        name: history_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
      }
      {
        name: help_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: description
            columns: 4
            col_width: 20
            col_padding: 2
            selection_rows: 4
            description_rows: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
      }

      {
        name: commands_menu
        only_buffer_difference: false
        marker: "# "
        type: {
            layout: columnar
            columns: 4
            col_width: 20
            col_padding: 2
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, position|
            $nu.scope.commands
            | where name =~ $buffer
            | each { |it| {value: $it.name description: $it.usage} }
        }
      }
  ]
  keybindings: [
    {
      name: completion_menu
      modifier: none
      keycode: tab
      mode: [vi_normal vi_insert]
      event: {
        until: [
          { send: menu name: completion_menu }
          { send: menunext }
        ]
      }
    }
    {
      name: completion_previous
      modifier: shift
      keycode: backtab
      mode: [vi_normal vi_insert]
      event: { send: menuprevious }
    }
    {
      name: unix-line-discard
      modifier: control
      keycode: char_u
      mode: [vi_normal vi_insert]
      event: {
        until: [
          {edit: cutfromlinestart}
        ]
      }
    }
    {
      name: kill-line
      modifier: control
      keycode: char_k
      mode: [vi_normal vi_insert]
      event: {
        until: [
          {edit: cuttolineend}
        ]
      }
    }


    {
      name: files_menu
      modifier: control
      keycode: char_f
      mode: [vi_normal vi_insert]
      event: { 
        send: executehostcommand 
        cmd: "commandline -a (
          ls **/*
          | get name
          | input list --fuzzy
        )"
      }
    }
    {
      name: commands_menu
      modifier: control
      keycode: char_t
      mode: [vi_normal vi_insert]
      event: { send: menu name: commands_menu }
    }
  ]
}
