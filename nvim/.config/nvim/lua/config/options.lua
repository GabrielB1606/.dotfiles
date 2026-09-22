require("config.remote_clipboard").setup()
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- Tabspace
vim.opt.tabstop = 2 -- Sets the number of spaces a tab character displays as
vim.opt.shiftwidth = 2 -- Sets the number of spaces to use for indentation
vim.opt.expandtab = true -- Replaces tabs with spaces when you press the Tab key

-- Line number
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- clipboard
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Sets how neovim will display certain whitespace characters in the editor. See :help 'list' and `:help 'listchars'
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Update time
vim.o.updatetime = 250

vim.opt.wrap = true
