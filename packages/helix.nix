{
  pkgs,
  my,
  base16,
  wrapPackage,
}: let
  lib = pkgs.lib;
in
  wrapPackage {
    pkg = pkgs.helix;
    name = "hx";
    vars = {
      "XDG_CONFIG_HOME" = "${placeholder "out"}/config";
    };

    path = with pkgs; [rnix-lsp];

    desktopItems = [
      (pkgs.makeDesktopItem {
        comment = "helix text editor";
        name = "helix";
        desktopName = "helix";
        genericName = "text editor";
        categories = ["TextEditor"];
        icon = "helix";
        exec = "hx";
        mimeTypes = [
          "text/english"
          "text/plain"
          "text/x-makefile"
          "text/x-c++hdr"
          "text/x-c++src"
          "text/x-chdr"
          "text/x-csrc"
          "text/x-java"
          "text/x-moc"
          "text/x-pascal"
          "text/x-tcl"
          "text/x-tex"
          "application/x-shellscript"
          "text/x-c"
          "text/x-c++"
          "text/x-bibtex"
        ];
      })
    ];

    files = {
      "config/helix/config.toml" = ''
        theme = "custom"

        [editor]
        auto-completion = true
        auto-format = true
        auto-pairs = false
        color-modes = true
        cursorline = true
        line-number = "relative"
        mouse = false

        [editor.soft-wrap]
        enable = true

        [editor.cursor-shape]
        insert = "bar"
        normal = "block"
        select = "block"

        [editor.lsp]
        display-messages = true

        [editor.statusline]
        center = ["file-name"]
        left = ["mode", "selections", "spinner"]
        right = ["diagnostics", "position-percentage", "file-type"]
      '';

      "config/helix/languages.toml" = ''
        [[language]]
        name = "rust"

        [language.config]
        checkOnSave = {command = "clippy"}
        cargo = {allFeatures = true}
        procMacro = {enable = true}
      '';

      "config/helix/themes/custom.toml" = with base16.withHashtag; ''
        "ui.background" = { bg = "${base00}" }
        "ui.virtual.whitespace" = "${base03}"

        "ui.linenr" = { fg = "${base03}", bg = "${base00}" }
        "ui.linenr.selected" = { fg = "${base04}", bg = "${base01}", modifiers = ["bold"] }

        "ui.menu" = { fg = "${base04}", bg = "${base01}"}
        "ui.menu.selected" = { fg = "${base01}", bg = "${base04}" }

        "ui.popup" = { bg = "${base01}", fg = "${base00}" }
        "ui.popup.info" = { bg = "${base01}", fg = "${base04}" }

        "ui.window" = { fg = "${base01}", bg = "${base01}" }
        "ui.statusline" = { fg = "${base04}", bg = "${base01}" }
        "ui.statusline.normal" = { fg = "${base04}", bg = "${base01}" }
        "ui.statusline.select" = { fg = "${base00}", bg = "${base09}" }
        "ui.statusline.insert" = { fg = "${base04}", bg = "${base01}" }

        "ui.cursor" = { fg = "${base04}", bg = "${base09}", modifiers = ["reversed"] }
        "ui.cursor.primary" = { fg = "${base04}", modifiers = ["bold", "reversed"] }
        "ui.cursor.match" = { fg = "${base09}", modifiers = [ "underlined"] }

        "ui.selection" = { bg = "${base02}" }

        "ui.cursorline.primary" = { bg = "${base01}" }

        "ui.text" = "${base05}"
        "ui.text.focus" = "${base05}"
        "ui.text.info" = "${base04}"

        "ui.help" = { fg = "${base04}", bg = "${base01}" }
        "ui.gutter" = { bg = "${base00}" }

        "comment" = { fg = "${base03}", modifiers = ["italic"] }
        "operator" = "${base09}"
        "variable" = "${base08}"
        "constant.numeric" = "${base09}"
        "constant" = "${base09}"
        "attribute" = "${base09}"
        "type" = "${base0A}"
        "string"  = "${base0B}"
        "variable.other.member" = "${base08}"
        "constant.character.escape" = "${base0C}"
        "function" = "${base0D}"
        "constructor" = "${base0D}"
        "special" = "${base0D}"
        "keyword" = "${base0E}"
        "label" = "${base0E}"
        "namespace" = "${base0E}"

        "markup.heading" = "${base0D}"
        "markup.list" = "${base08}"
        "markup.bold" = { fg = "${base0A}", modifiers = ["bold"] }
        "markup.italic" = { fg = "${base0E}", modifiers = ["italic"] }
        "markup.link.url" = { fg = "${base09}", modifiers = ["underlined"] }
        "markup.link.text" = "${base08}"
        "markup.quote" = "${base0C}"
        "markup.raw" = "${base0B}"

        "diff.plus" = "${base0B}"
        "diff.delta" = "${base09}"
        "diff.minus" = "${base08}"

        "diagnostic" = { modifiers = ["underlined"] }
        "info" = "${base0D}"
        "hint" = "${base03}"
        "debug" = "${base03}"
        "warning" = "${base09}"
        "error" = "${base08}"
      '';
    };
  }
