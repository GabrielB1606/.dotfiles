require("telescope").setup({})

local builtin = require('telescope.builtin')

-- files
vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Search files' })
vim.keymap.set('n', '<leader>p', builtin.oldfiles, { desc = 'Search opened files' })
vim.keymap.set('n', '<C-f>', builtin.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader><C-f>', builtin.grep_string, { desc = 'Telescope grep' })
vim.keymap.set('v', '<leader><C-f>', builtin.grep_string, { desc = 'Telescope grep' })

-- buffers
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Search buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Search help tags' })
vim.keymap.set('n', '<leader>fm', builtin.marks, { desc = 'Search marks' })

-- misc
vim.keymap.set('n', '<leader>ff', builtin.resume, { desc = 'Resume search' })

-- lsp
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'Find references' })
vim.keymap.set('n', '<leader>fd', builtin.lsp_definitions, { desc = 'Find definition' })
vim.keymap.set('n', '<leader>fi', builtin.lsp_implementations, { desc = 'Find implementation' })
vim.keymap.set('n', '<leader>ft', builtin.lsp_type_definitions, { desc = 'Find type definition' })

-- diagnostics
vim.keymap.set('n', '<leader>xx', builtin.diagnostics, { desc = 'Diagnostics' })
vim.keymap.set('n', '<leader>xq', builtin.quickfix, { desc = 'Quickfix list' })
