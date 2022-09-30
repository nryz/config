{ config, lib, pkgs, extraPkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.blocks.programs.helix;
in
{
  options.blocks.programs.helix = with types; {
    enable = mkOpt bool false;
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      rnix-lsp
    ];
    
    programs.helix = {
      # package = extraPkgs.helix.default;
      enable = true;
      
      languages = [ 
      { name = "rust"; 
        config = {
          checkOnSave = { command = "clippy"; };
          cargo = { allFeatures = true; };
          procMacro = { enable = true; };
      };}
      ];
      
      settings = {
        theme = "custom";
        
        editor = {
          mouse = false;
          line-number = "relative";
          auto-pairs = false;
          cursorline = true;
          auto-completion = true;
          auto-format = true;
          color-modes = true;
          
          statusline = {
            left = [ "mode" "selections" "spinner" ];
            center = [ "file-name" ];
            right = [ "diagnostics" "position-percentage" "file-type" ];
          };
          
          lsp = {
            display-messages = true;
          };
          
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "block";
          };
        };
      };
      
      themes.custom = with config.scheme.withHashtag; {
        "ui.background" = { bg = base00; };
        "ui.virtual.whitespace" = base03;

        "ui.linenr" = { fg = base03; bg = base00; };
        "ui.linenr.selected" = { fg = base04; bg = base01; modifiers = ["bold"]; };

        "ui.menu" = base04;
        "ui.menu.selected" = { fg = base01; bg = base04; };

        "ui.popup" = { bg = base00; };
        "ui.popup.info" = base04;

        "ui.window" = { bg = base01; };
        "ui.statusline" = { fg = base04; bg = base01; };

        "ui.cursor" = { fg = base04; bg = base0A; };
        "ui.cursor.primary" = { fg = base05; modifiers = ["reversed"]; };
        "ui.cursor.match" = { fg = base0A; modifiers = ["underlined"]; };

        "ui.selection" = { bg = base02; };

        "ui.cursorline.primary" = { bg = base01; };

        "ui.text" = base05;
        "ui.text.focus" = base05;
        "ui.text.info" = base04;

        "ui.help" = { fg = base04; bg = base01; };
        "ui.gutter" = { bg = base01; };

        "comment" = { fg = base03; modifiers = ["italic"]; };
        "operator" = base09;
        "variable" = base08;
        "constant.numeric" = base09;
        "constant" = base09;
        "attribute" = base09;
        "type" = base0A;
        "string"  = base0B;
        "variable.other.member" = base08;
        "constant.character.escape" = base0C;
        "function" = base0D;
        "constructor" = base0D;
        "special" = base0D;
        "keyword" = base0E;
        "label" = base0E;
        "namespace" = base0E;

        "markup.heading" = base0D;
        "markup.list" = base08;
        "markup.bold" = { fg = base0A; modifiers = ["bold"]; };
        "markup.italic" = { fg = base0E; modifiers = ["italic"]; };
        "markup.link.url" = { fg = base09; modifiers = ["underlined"]; };
        "markup.link.text" = base08;
        "markup.quote" = base0C;
        "markup.raw" = base0B;

        "diff.plus" = base0B;
        "diff.delta" = base09;
        "diff.minus" = base08;

        "diagnostic" = { modifiers = ["underlined"]; };
        "info" = base0D;
        "hint" = base03;
        "debug" = base03;
        "warning" = base09;
        "error" = base08;
      };
    };

    # xdg.configFile."helix/languages.toml".text = ''
    #   [[language]]
    #   name="rust"
    #   [language.config]
    #   checkOnSave = {command = "clippy"}
    #   cargo = {allFeatures = true}
    #   procMacro = {enable = true }
    #   auto-format = true
    # '';

    # xdg.configFile."helix/config.toml".text = ''
    #   theme = "custom"

    #   [editor]
    #   mouse = false
    #   line-number = "relative"
    #   auto-pairs = false
    #   cursorline = true
    #   auto-completion = true
    #   auto-format = true
    #   color-modes = true
      
    #   [editor.statusline]
    #   left = ["mode", "selections", "spinner"]
    #   center = ["file-name"]
    #   right = ["diagnostics", "position-percentage", "file-type"]
            
    #   [editor.lsp]
    #   display-messages = true
      
    #   [editor.cursor-shape]
    #   normal = "block"
    #   insert = "bar"
    #   select = "block"
    # '';

    # xdg.configFile."helix/themes/custom.toml".text = with config.scheme.withHashtag; ''
    #   "ui.background" = { bg = "base00" }
    #   "ui.virtual.whitespace" = "base03"

    #   "ui.linenr" = { fg = "base03", bg = "base00" }
    #   "ui.linenr.selected" = { fg = "base04", bg = "base01", modifiers = ["bold"] }

    #   "ui.menu" = "base04"
    #   "ui.menu.selected" = { fg = "base01", bg = "base04" }

    #   "ui.popup" = { bg = "base00" }
    #   "ui.popup.info" = "base04"

    #   "ui.window" = { bg = "base01" }
    #   "ui.statusline" = { fg = "base04", bg = "base01" }
    #   "ui.help" = { fg = "base04", bg = "base01" }

    #   "ui.cursor" = { fg = "base04", bg = "base0A" }
    #   "ui.cursor.primary" = { fg = "base05", modifiers = ["reversed"] }
    #   "ui.cursor.match" = { fg = "base0A", modifiers = ["underlined"] }

    #   "ui.selection" = { bg = "base02"}

    #   "ui.cursorline.primary" = { bg = "base01" }

    #   "ui.text" = "base05"
    #   "ui.text.focus" = "base05"
    #   "ui.text.info" = "base04"

    #   "ui.help" = { fg = "base04", bg = "base01" }
    #   "ui.gutter" = { bg = "base01" }

    #   "comment" = { fg = "base03", modifiers = ["italic"] }
    #   "operator" = "base09"
    #   "variable" = "base08"
    #   "constant.numeric" = "base09"
    #   "constant" = "base09"
    #   "attribute" = "base09"
    #   "type" = "base0A"
    #   "string"  = "base0B"
    #   "variable.other.member" = "base08"
    #   "constant.character.escape" = "base0C"
    #   "function" = "base0D"
    #   "constructor" = "base0D"
    #   "special" = "base0D"
    #   "keyword" = "base0E"
    #   "label" = "base0E"
    #   "namespace" = "base0E"

    #   "markup.heading" = "base0D"
    #   "markup.list" = "base08"
    #   "markup.bold" = { fg = "base0A", modifiers = ["bold"] }
    #   "markup.italic" = { fg = "base0E", modifiers = ["italic"] }
    #   "markup.link.url" = { fg = "base09", modifiers = ["underlined"] }
    #   "markup.link.text" = "base08"
    #   "markup.quote" = "base0C"
    #   "markup.raw" = "base0B"

    #   "diff.plus" = "base0B"
    #   "diff.delta" = "base09"
    #   "diff.minus" = "base08"

    #   "diagnostic" = { modifiers = ["underlined"] }
    #   "info" = "base0D"
    #   "hint" = "base03"
    #   "debug" = "base03"
    #   "warning" = "base09"
    #   "error" = "base08"

    #   [palette]
    #   base00 = "${base00}" # Default Background
    #   base01 = "${base01}" # Lighter Background (Used for status bars, line number and folding marks)
    #   base02 = "${base02}" # Selection Background
    #   base03 = "${base03}" # Comments, Invisibles, Line Highlighting
    #   base04 = "${base04}" # Dark Foreground (Used for status bars)
    #   base05 = "${base05}" # Default Foreground, Caret, Delimiters, Operators
    #   base06 = "${base06}" # Light Foreground (Not often used)
    #   base07 = "${base07}" # Light Background (Not often used)
    #   base08 = "${base08}" # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
    #   base09 = "${base09}" # Integers, Boolean, Constants, XML Attributes, Markup Link Url
    #   base0A = "${base0A}" # Classes, Markup Bold, Search Text Background
    #   base0B = "${base0B}" # Strings, Inherited Class, Markup Code, Diff Inserted
    #   base0C = "${base0C}" # Support, Regular Expressions, Escape Characters, Markup Quotes
    #   base0D = "${base0D}" # Functions, Methods, Attribute IDs, Headings
    #   base0E = "${base0E}" # Keywords, Storage, Selector, Markup Italic, Diff Changed
    #   base0F = "${base0F}" # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
    # '';
  };
}
