local lspconfig = require("lspconfig")
local vars = require("vars")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

lspconfig.rnix.setup {capabilities = capabilities}

lspconfig.pyright.setup {capabilities = capabilities}

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

lspconfig.sumneko_lua.setup {
  cmd = {
    vars.lualanguageserverPath .. "/bin/lua-language-server", "-E",
    vars.lualanguageserverPath .. "/share/lua-language-server/main.lua"
  },
  capabilities = capabilities,
  settings = {
    lua = {
      runtime = {version = 'LuaJIT', path = runtime_path},
      diagnostics = {
        globals = {'vim', 'use' }
      },
      workspace = {
        -- library = vim.api.nvim_get_runtime_file('', true),
        library = {[vim.fn.expand('$VIMRUNTIME/lua')] = true, [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true}
      },
      telemetry = {enable = false}
    }
  }
}

lspconfig.efm.setup {
  init_options = {documentFormatting = true},
  filetypes = {"lua"},
  settings = {
    rootMarkers = {".git/"},
    languages = {
      lua = {
        {
          formatCommand = "lua-format -i --no-keep-simple-function-one-line --no-break-after-operator --column-limit=150 --break-after-table-lb",
          formatStdin = true
        }
      }
    }
  }
}

require("rust-tools").setup {
  tools = {
    autoSetHints = true,
    hover_with_actions = true,
    inlay_hints = {
      show_parameter_hints = false,
      parameter_hints_prefix = "",
      other_hints_prefix = "",
    },
  },

  server = {
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy"
        },
      },
    },
  },
}

vim.diagnostic.config {signs = false}
