require("mini.icons").setup({})

require("oil").setup({
  default_file_explorer = true,
  columns = { "icon" },
  delete_to_trash = true,
  view_options = {
    show_hidden = true,
  },
  keymaps = {
    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
    -- Free <C-h>/<C-l> for window navigation (see keymaps.lua).
    ["<C-h>"] = false,
    ["<C-l>"] = false,
  },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory (Oil)" })
vim.keymap.set("n", "<C-b>", "<CMD>Oil --float<CR>", { desc = "Oil file explorer (float)" })
