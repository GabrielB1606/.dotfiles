-- Open netrw as a left-hand sidebar (similar to VS Code)
vim.keymap.set('n', '<C-b>', ':Lexplore<CR>', { noremap = true, silent = true, desc = 'Toggle netrw' })

-- Set netrw to take up 30% of the screen width
vim.g.netrw_winsize = 30

-- Hide the chunky netrw help banner
vim.g.netrw_banner = 0

-- Set the default list style to tree view
vim.g.netrw_liststyle = 3

-- Custom keymaps specifically for netrw
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'netrw',
  callback = function()
    -- Map 'a' to add a file without opening it
    vim.keymap.set('n', 'a', function()
      -- Prompt for the new file name
      local name = vim.fn.input('New file: ')
      if name == '' then return end -- Cancel if no name is provided

      -- Construct the file path and create the empty file
      local path = vim.b.netrw_curdir .. '/' .. name
      vim.fn.writefile({}, path)

      -- Simulate pressing Ctrl+L to refresh the netrw window (using 'm' to trigger the remap)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-l>', true, false, true), 'm', false)
    end, { buffer = true, desc = 'Create file without opening' })

    -- Map 'Enter' to open a file and automatically close the sidebar
    vim.keymap.set('n', '<CR>', function()
      local line = vim.fn.getline('.')

      -- If it's a file, schedule the sidebar to close immediately after the file opens
      if not (line:match('/$') or line:match('^"')) then
        vim.schedule(function()
          vim.cmd('Lexplore')
        end)
      end

      -- Trigger netrw's safe, internal open command to avoid infinite loops
      return '<Plug>NetrwLocalBrowseCheck'
    end, { buffer = true, expr = true, remap = true, desc = 'Open file and close netrw' })
  end
})
