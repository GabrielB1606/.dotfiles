--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- lazygit
vim.keymap.set("n", "<leader>gg", ":LazyGit<CR>", { desc = "Open LazyGit" })

-- Trigger native LSP omni-completion in Insert mode
vim.keymap.set('i', '<C-J>', '<C-x><C-o>', { desc = 'Trigger autocomplete' })

-- Rename symbol under cursor
vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, { desc = 'Rename' })

-- Line Swaps
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Comments
vim.keymap.set("n", "<C-_>", ":norm gcc<CR>")
vim.keymap.set("v", "<C-_>", ":norm gcc<CR>")

-- Replace with clipboard
vim.keymap.set("x", "<leader>r", [["_dP]], { desc = "Replace current selection with clipboard content" })
vim.keymap.set("v", "<C-y>", '"+y', { noremap = true, silent = true })

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
