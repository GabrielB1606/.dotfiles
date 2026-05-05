-- Basic Configuration
vim.opt.number = true             -- Show line numbers
vim.opt.relativenumber = true     -- Relative line numbers
vim.opt.mouse = 'a'               -- Enable mouse support
vim.opt.clipboard = 'unnamedplus' -- Sync with Windows clipboard
vim.opt.swapfile = false
vim.opt.signcolumn = "yes"
vim.opt.winborder = "rounded"
vim.g.mapleader = " "
vim.opt.list = true          -- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split" -- Preview substitutions live, as you type!
vim.opt.scrolloff = 10       -- Minimal number of screen lines to keep above and below the cursor.
vim.o.updatetime = 250       -- Update time
vim.opt.wrap = true

-- Indentation and Tab settings
vim.opt.tabstop = 2      -- Number of spaces a <Tab> in the file counts for
vim.opt.shiftwidth = 2   -- Number of spaces to use for auto-indenting
vim.opt.expandtab = true -- Converts Tab presses into standard spaces
vim.opt.softtabstop = 2  -- Number of spaces a <Tab> counts for when editing/deleting

-- Packages
vim.pack.add({
  -- basic
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/kdheepak/lazygit.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/Civitasv/cmake-tools.nvim" },
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    branch = "main",
    build = ':TSUpdate'
  },

  -- debug
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },

  -- mini
  { src = "https://github.com/nvim-mini/mini.extra" },
  { src = "https://github.com/nvim-mini/mini.pairs" },

  -- just for the sake of AI lol
  { src = "https://github.com/MunifTanjim/nui.nvim" },
  { src = "https://github.com/github/copilot.vim" },
  { src = "https://github.com/yetone/avante.nvim" },
})

-- LSP config
vim.lsp.enable({ "lua_ls", "clangd", "glsl_analyzer", "ccls", "wgsl_analyzer", "cmake", "neocmake" })
vim.keymap.set('n', '<leader>==', vim.lsp.buf.format) -- autoformatting

--- Autocomplete
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method('textDocument/completion') then
      -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})

vim.cmd [[set completeopt+=menuone,noselect,popup]]

-- Autoformat on save using the attached LSP
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function(args)
    -- Tell the LSP to format the current buffer
    vim.lsp.buf.format({
      bufnr = args.buf,
      async = false
    })
  end,
})

-- Language specific LSP configurations

-- C++
vim.lsp.config("clangd", {
  before_init = function(_, client_config)
    local ok, cmake = pcall(require, "cmake-tools")
    if ok then
      cmake.clangd_on_new_config(client_config)
    end
  end,
  cmd = {
    "clangd",
    "--background-index",
    "--compile-commands-dir=build",
    "--query-driver=D:/dev/mingw64/bin/g++.exe",
    "--query-driver=C:/Program Files/Microsoft Visual Studio/*/*/VC/Tools/MSVC/*/bin/Hostx64/x64/cl.exe",
    "--query-driver=C:/Program Files/Microsoft Visual Studio/*/*/VC/Tools/MSVC/*/bin/Hostx64/x86/cl.exe",
  },
  init_options = {
    fallbackFlags = {
      "-target",
      "x86_64-w64-mingw32",
    }
  }
})

-- import other configs
require('netrw')
require('keymaps')
require('plugins.mini')
require('plugins.avante')
require('plugins.treesitter')
require('plugins.telescope')
require('plugins.which-key')
require('plugins.dap')
require('plugins.cmake')
