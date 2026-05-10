-- Disable netrw in favor of Oil for directory buffers.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local project = require("project")

-- Basic Configuration
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.signcolumn = "yes"
vim.opt.winborder = "rounded"
vim.g.mapleader = " "
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.scrolloff = 10
vim.o.updatetime = 250
vim.opt.wrap = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2

local cpp_plugin_specs = {
  { src = "https://github.com/Civitasv/cmake-tools.nvim" },
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },
}

local packs = {
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/kdheepak/lazygit.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
  },
  { src = "https://github.com/nvim-mini/mini.extra" },
  { src = "https://github.com/nvim-mini/mini.pairs" },
  { src = "https://github.com/nvim-mini/mini.icons" },
  { src = "https://github.com/nvim-mini/mini.pick" },
  { src = "https://github.com/MunifTanjim/nui.nvim" },
  { src = "https://github.com/github/copilot.vim" },
  { src = "https://github.com/yetone/avante.nvim" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
}

project.detect()
if project.is_cpp then
  vim.list_extend(packs, cpp_plugin_specs)
  vim.g.__my_cpp_plugins_added = 1
end

vim.pack.add(packs)

require("plugins.mason")
require("plugins.oil")

require("keymaps")
require("plugins.mini")
require("plugins.avante")
require("plugins.treesitter")
require("plugins.telescope")

require("plugins.lsp")

local last_bootstrap_key = ""

local function bootstrap_tooling(reason)
  project.detect()

  -- If we started outside a C++ tree but later open one, pull in the native tooling pack.
  if project.is_cpp and not vim.g.__my_cpp_plugins_added then
    vim.pack.add(cpp_plugin_specs)
    vim.g.__my_cpp_plugins_added = 1
  end

  local key = table.concat({
    project.root or "",
    project.is_web and "w" or "-",
    project.is_cpp and "c" or "-",
  }, "|")

  if key == last_bootstrap_key then
    return
  end
  last_bootstrap_key = key

  if project.is_cpp then
    require("plugins.cpp")
  end

  if project.is_web then
    require("plugins.web")
  end

  require("plugins.mason").ensure_tooling()
  require("plugins.lsp").apply_enable()
  require("plugins.which-key").setup()
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    bootstrap_tooling("VimEnter")
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "DirChanged" }, {
  callback = function()
    vim.schedule(function()
      bootstrap_tooling("fs")
    end)
  end,
})
