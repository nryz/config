{ config, lib, pkgs, packages, ... }:

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

    hm.home.packages = with pkgs; [
      rnix-lsp
    ];
    
    hm.programs.helix = {
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
  };
}
