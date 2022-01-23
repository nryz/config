vim.g.mapleader = ' '

local keymap = vim.api.nvim_set_keymap
keymap('n', 's', "<cmd>HopChar1CurrentLine<cr>", {})
keymap('n', 'S', "<cmd>HopChar1<cr>", {})

local opts = { noremap = true }
keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
keymap('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
keymap('n', '<c-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)

local wk = require("which-key")
wk.register({
  w = {"<cmd>HopWord<cr>", "word"},
  l = {"<cmd>HopLine<cr>", "line"},
  p = {"<cmd>hoppattern<cr>", "pattern"},
  c = {"<cmd>hopchar2<cr>", "char2"},
}, { prefix = ","})

wk.register({
  w = {"<cmd>w!<cr>", "save"},

  h = {"<C-W>h", "focus window left"},
  j = {"<C-W>j", "focus window down"},
  k = {"<C-W>k", "focus window up"},
  l = {"<C-W>l", "focus window right"},

  b = {"<cmd>lua require('fzf-lua').buffers()<cr>", "buffers"},
  t = {"<cmd>lua require('fzf-lua').tabs()<cr>", "tabs"},
  m = {"<cmd>lua require('fzf-lua').marks()<cr>", "marks"},
  y = {"<cmd>lua require('fzf-lua').jumps()<cr>", "yumps"},

  o = {
    name = "+open",
    t = {"<cmd>tabnew<cr>", "tab"},
    v = {"<cmd>vnew<cr>", "new vertical window"},
    V = {"<cmd>vsplit<cr>", "new vertical split"},
    h = {"<cmd>new<cr>", "new horizontal window"},
    H = {"<cmd>split<cr>", "new horizontal split"},
    q = {"<cmd>copen<cr>", "quickfix"},
    l = {"<cmd>lopen<cr>", "loclist"},
  },

  c = {
    name = "+close",
    b = {"<cmd>bd<cr>", "buffer"},
    w = {"<cmd>close<cr>", "window"},
    t = {"<cmd>tabclose<cr>", "tab"},
    q = {"<cmd>cclose<cr>", "quickfix"},
    l = {"<cmd>lclose<cr>", "loclist"},
  },

  e = {
    name = "+go",
    l = {"<cmd>lnext<cr>", "loclist next"},
    L = {"<cmd>lprevious<cr>", "loclist previous"},
    q = {"<cmd>qnext<cr>", "quickfix next"},
    Q = {"<cmd>qprevious<cr>", "quickfix previous"},
  },

  f = {
    name = "+find",
    f = {"<cmd>lua require('fzf-lua').files()<cr>", "files"},
    o = {"<cmd>lua require('fzf-lua').oldfiles()<cr>", "old files"},
    b = {"<cmd>lua require('fzf-lua').blines()<cr>", "buffer lines (current)"},
    B = {"<cmd>lua require('fzf-lua').lines()<cr>", "buffer lines (open)"},
    q = {"<cmd>lua require('fzf-lua').quickfix()<cr>", "quickfix"},
    l = {"<cmd>lua require('fzf-lua').loclist()<cr>", "loclist"},
  },

  a = {
    name = "+additional",
    b = {"<cmd>lua require('fzf-lua').builtin()<cr>", "builtin"},
    h = {"<cmd>lua require('fzf-lua').help_tags()<cr>", "help_tags"},
    c = {"<cmd>lua require('fzf-lua').commands()<cr>", "commands"},
    C = {"<cmd>lua require('fzf-lua').command_history()<cr>", "command history"},
    r = {"<cmd>lua require('fzf-lua').registers()<cr>", "registers"},
    k = {"<cmd>lua require('fzf-lua').keymaps()<cr>", "key mappings"},
    s = {"<cmd>lua require('fzf-lua').spell_suggest()<cr>", "spelling suggestions"},
    t = {"<cmd>lua require('fzf-lua').tags()<cr>", "tags (buffer)"},
    T = {"<cmd>lua require('fzf-lua').btags()<cr>", "tags (project)"},
    f = {"<cmd>lua require('fzf-lua').filetypes()<cr>", "filetypes"},
    H = {"<cmd>lua require('fzf-lua').search_history()<cr>", "search history"},
  },

  g = {
    name = "+grep",
    g = {"<cmd>lua require('fzf-lua').grep_curbuf()<cr>", "grep (buffer)"},
    G = {"<cmd>lua require('fzf-lua').live_grep_native()<cr>", "grep (project)"},
    w = {"<cmd>lua require('fzf-lua').grep_cword()<cr>", "word under cursor"},
    W = {"<cmd>lua require('fzf-lua').grep_cword()<cr>", "WORD under cursor"},
    v = {"<cmd>lua require('fzf-lua').grep_visual()<cr>", "visual"},
    p = {"<cmd>lua require('fzf-lua').grep()<cr>", "pattern"},
    r = {"<cmd>lua require('fzf-lua').grep_last()<cr>", "repeat last pattern"},
  },

  u = {
    name = "+under cursor",
    r = {"<cmd>lua require('fzf-lua').lsp_references()<cr>", "references"},
    d = {"<cmd>lua require('fzf-lua').lsp_definitions()<cr>", "definitions"},
    D = {"<cmd>lua require('fzf-lua').lsp_declarations()<cr>", "declarations"},
    t = {"<cmd>lua require('fzf-lua').lsp_typedefs()<cr>", "typedefs"},
    i = {"<cmd>lua require('fzf-lua').lsp_implementations()<cr>", "implementations"},
    n = {"<cmd>lua vim.lsp.buf.rename()<cr>", "rename"},
  },

  d = {
    name = "+lsp",
    s = {"<cmd>lua require('fzf-lua').lsp_document_symbols()<cr>", "symbols (buffer)"},
    S = {"<cmd>lua require('fzf-lua').lsp_workspace_symbols()<cr>", "symbols (workspace)"},
    a = {"<cmd>lua require('fzf-lua').lsp_code_actions()<cr>", "code actions"},
    d = {"<cmd>lua require('fzf-lua').lsp_document_diagnostics()<cr>", "diagnostics (buffer)"},
    D = {"<cmd>lua require('fzf-lua').lsp_workspace_diagnostics()<cr>", "diagnostics (workspace)"},
  },

  v = {
    name = "+version control (git)",
    f = {"<cmd>lua require('fzf-lua').git_files()<cr>", "files"},
    s = {"<cmd>lua require('fzf-lua').git_status()<cr>", "status"},
    c = {"<cmd>lua require('fzf-lua').git_bcommits()<cr>", "commit log (buffer)"},
    C = {"<cmd>lua require('fzf-lua').git_commits()<cr>", "commit log (project)"},
    b = {"<cmd>lua require('fzf-lua').git_branches()<cr>", "branches"},
  },
}, { prefix = "<leader>"})
