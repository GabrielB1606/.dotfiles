-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Line Swaps
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Comments
vim.keymap.set("n", "<C-_>", ":norm gcc<CR>")
vim.keymap.set("v", "<C-_>", ":norm gcc<CR>")

-- Replace with clipboard
vim.keymap.set("x", "<leader>r", [["_dP]], { desc = "Replace current selection with clipboard content" })
vim.keymap.set("v", "<C-y>", '"+y', { noremap = true, silent = true })

-- Replace all coincidences in file
vim.keymap.set("n", "<leader>~", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Wrap stuff
vim.api.nvim_set_keymap("v", "<leader>w[", [[c[<c-r>"]<esc>]], { noremap = false, desc = "Wrap with []" })
vim.api.nvim_set_keymap("v", "<leader>w(", [[c(<c-r>")<esc>]], { noremap = false, desc = "Wrap with ()" })
vim.api.nvim_set_keymap(
  "v",
  "<leader>wcl",
  [[cconsole.log(<c-r>")<esc>]],
  { noremap = false, desc = "Wrap with console.log()" }
)
vim.api.nvim_set_keymap(
  "v",
  "<leader>cd",
  [[cconsole.debug(<c-r>")<esc>]],
  { noremap = false, desc = "Wrap with console.debug()" }
)
vim.api.nvim_set_keymap(
  "v",
  "<leader>ce",
  [[cconsole.error(<c-r>")<esc>]],
  { noremap = false, desc = "Wrap with console.debug()" }
)
vim.api.nvim_set_keymap("v", "<leader>w{", [[c{<c-r>"}<esc>]], { noremap = false, desc = "Wrap with {}" })
vim.api.nvim_set_keymap("v", "<leader>w'", [[c'<c-r>"'<esc>]], { noremap = false, desc = "Wrap with ''" })
vim.api.nvim_set_keymap("v", '<leader>w"', [[c"<c-r>""<esc>]], { noremap = false, desc = 'Wrap with ""' })
vim.api.nvim_set_keymap("v", "<leader>w`", [[c`<c-r>"`<esc>]], { noremap = false, desc = "Wrap with ``" })
vim.api.nvim_set_keymap("v", "<leader>we", [[c`${<c-r>"}`<esc>]], { noremap = false, desc = "Wrap with `${}`" })
vim.api.nvim_set_keymap("v", "<leader>wt", [[c<><c-r>"</><esc>]], { noremap = false, desc = "Wrap with <>" })

-- Quicklist
vim.keymap.set("n", "<leader>,", "<cmd>cprev<CR>", { desc = "PrevNextquicklist item" })
vim.keymap.set("n", "<leader>.", "<cmd>cnext<CR>", { desc = "Next quicklist item" })

-- set <C-b> to toggle nvim-tree
vim.keymap.set("n", "<C-b>", "<cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })

-- Notebooks: <leader>n is freed and notification history moved to <leader>nn
-- (see lua/plugins/lazyvim-overrides.lua and lua/plugins/jupyter.lua)
vim.keymap.set("n", "<leader>nn", function()
  local Snacks = require("snacks")
  if Snacks.config.picker and Snacks.config.picker.enabled then
    Snacks.picker.notifications()
  else
    Snacks.notifier.show_history()
  end
end, { desc = "Notification History" })
