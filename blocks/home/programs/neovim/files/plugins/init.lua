local vars = require("vars")

require("plugins.nvim-lspconfig")
require("plugins.nvim-cmp")

require("hop").setup {}

require("dapui").setup {}
local dap = require('dap')
dap.adapters.lldb = {
  type = 'executable',
  command = vars.lldbvscodePath,
  name = "lldb",
}

dap.configurations.rust = {
  {
    name = "Launch",
    type = "lldb",
    request = "Launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},

    runInTerminal = false,
  },
}

require("lualine").setup {
  options = {
    theme = vars.lualine,
    section_separators = '',
    component_separators = ''
  }
}

require("trouble").setup {}

require("stabilize").setup {}

require("rust-tools").setup {}

local configs = require("nvim-treesitter.configs")
configs.setup {
  ensure_installed = "maintained",
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  }
}

