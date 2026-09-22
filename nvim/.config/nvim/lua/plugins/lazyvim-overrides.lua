-- Free the <leader>n prefix so it can be used for notebook keymaps
-- (<leader>nb...) while moving notification history to <leader>nn.
--
-- LazyVim registers <leader>n "Notification History" as a lazy.nvim `keys`
-- spec on snacks.nvim (lazyvim.plugins.ui and the snacks_picker extra).
-- lazy.nvim merges keys specs from all matching plugin specs and re-installs
-- them whenever the plugin loads, so we remove the offending key from the
-- merged values cache and the handler table, and delete the mapping itself.
local function free_leader_n()
  local ok, lazy = pcall(require, "lazy")
  if not ok then
    return
  end
  for _, plugin in ipairs(lazy.plugins()) do
    if plugin.name == "snacks.nvim" then
      local cache = plugin._.cache or {}
      local list = cache.keys_list or {}
      for i, key in ipairs(list) do
        if key and key.lhs == "<leader>n" then
          table.remove(list, i)
          break
        end
      end
      local handlers = plugin._.handlers or {}
      local keys = handlers.keys or {}
      for id, key in pairs(keys) do
        if key.lhs == "<leader>n" then
          keys[id] = nil
        end
      end
      pcall(vim.keymap.del, "n", "<leader>n")
    end
  end
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = free_leader_n,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  callback = function(event)
    if event.data == "snacks.nvim" then
      vim.defer_fn(free_leader_n, 0)
    end
  end,
})

return {}
