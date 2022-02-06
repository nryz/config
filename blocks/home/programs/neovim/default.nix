{ config, lib, pkgs, extraPkgs, inputs, ... }:

with lib;
with lib.my;
{
  persist.directories = [ ".local/share/nvim" ];

  home.packages = with pkgs; [
    gcc
  ];

  xdg.configFile."nvim/lua" = {
    source = ./files;
    recursive = true;
  };

  xdg.configFile."nvim/lua/vars.lua".text = with config.scheme.withHashtag; ''
      local vars = {}

      vim.cmd [[highlight WhichKeyFloat guibg=${base01}]]
      vim.cmd [[highlight linenr guibg=${base00}]]

      vars.lldbvscodePath = "${pkgs.vscode-extensions.llvm-org.lldb-vscode}/bin/lldb-vscode"
      vars.lualanguageserverPath = "${pkgs.sumneko-lua-language-server}"

      vars.lualine = {
        normal = {
            a = {bg = "${base0C}", fg = "${base00}", gui = 'bold'},
            b = {bg = "${base02}", fg = "${base04}"},
            c = {bg = "${base01}", fg = "${base05}"}
          },
          insert = {
            a = {bg = "${base09}", fg = "${base00}", gui = 'bold'},
            b = {bg = "${base02}", fg = "${base04}"},
            c = {bg = "${base01}", fg = "${base05}"}
          },
          visual = {
            a = {bg = "${base0A}", fg = "${base00}", gui = 'bold'},
            b = {bg = "${base02}", fg = "${base04}"},
            c = {bg = "${base01}", fg = "${base05}"}
          },
          replace = {
            a = {bg = "${base0B}", fg = "${base00}", gui = 'bold'},
            b = {bg = "${base02}", fg = "${base04}"},
            c = {bg = "${base01}", fg = "${base05}"}
          },
          command = {
            a = {bg = "${base0D}", fg = "${base00}", gui = 'bold'},
            b = {bg = "${base02}", fg = "${base04}"},
            c = {bg = "${base01}", fg = "${base05}"}
          },
          inactive = {
            a = {bg = "${base01}", fg = "${base05}", gui = 'bold'},
            b = {bg = "${base01}", fg = "${base04}"},
            c = {bg = "${base01}", fg = "${base05}"}
          }
      }

      return vars
  '';

  programs.neovim = {
    package = pkgs.neovim-nightly;
    enable = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      extraPkgs.vimPlugins.which-key-nvim
      extraPkgs.vimPlugins.fzf-lua
      lualine-nvim
      hop-nvim
      nvim-web-devicons
      plenary-nvim
      diffview-nvim
      kommentary
      stabilize-nvim

      #lsp
      nvim-lspconfig
      lspkind-nvim
      lsp-colors-nvim
      trouble-nvim
      rust-tools-nvim

      vim-nix
      #(nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
      nvim-treesitter

      #cmp
      nvim-cmp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-nvim-lsp

      nvim-dap
      nvim-dap-ui

      #snippets
      luasnip
      cmp_luasnip
    ] ++ [(pkgs.vimPlugins.base16-vim.overrideAttrs (old:
         let schemeFile = config.scheme inputs.base16-vim;
         in { patchPhase = '' cp ${schemeFile} colors/base16-scheme.vim ''; })
    )];

    extraConfig = ''
      set termguicolors
      set background=dark
      colorscheme base16-scheme
      let base16colorspace=256
      
      lua << EOF
        vim.lsp.set_log_level("debug")

        require("settings")
        require("keybindings")
        require("plugins.init")
      EOF
    '';

    extraPackages = with pkgs; [
      tree-sitter
      rnix-lsp
      sumneko-lua-language-server
      rust-analyzer
      efm-langserver
      lua
      luaformatter
      pyright
    ];
  };
}
