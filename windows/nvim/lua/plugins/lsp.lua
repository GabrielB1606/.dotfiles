local project = require("project")

--- Prefer eslint for TS/JS when it can format; else ts_ls / others.
local WEB_SYNC_FTS = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
  vue = true,
}

local M = {}

function M.format_filter(client)
  return M.format_filter_for(0, client)
end

---@param bufnr integer
---@param client vim.lsp.Client
function M.format_filter_for(bufnr, client)
  bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
  local ft = vim.bo[bufnr].filetype
  local name = client.name

  local method = "textDocument/formatting"
  if not client.supports_method(method) then
    return false
  end

  if ft == "lua" then
    return name == "lua_ls"
  end

  if vim.tbl_contains({ "c", "cpp", "objc", "objcpp", "cuda" }, ft) then
    return name == "clangd"
  end

  if WEB_SYNC_FTS[ft] then
    local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method })
    local function has(name_)
      for _, cl in ipairs(clients) do
        if cl.name == name_ and cl.supports_method(method) then
          return true
        end
      end
      return false
    end
    if has("eslint") then
      return name == "eslint"
    end
    return name == "ts_ls"
  end

  if ft == "json" or ft == "jsonc" then
    return name == "jsonls"
  end

  if ft == "css" or ft == "scss" or ft == "less" then
    return name == "tailwindcss" or name == "cssls"
  end

  if ft == "html" or ft == "htmldjango" then
    return name == "html"
  end

  if ft == "markdown" then
    return false
  end

  if ft == "cmake" then
    return name == "neocmake" or name == "cmake"
  end

  if ft == "glsl" then
    return name == "glsl_analyzer"
  end

  if ft == "wgsl" then
    return name == "wgsl_analyzer"
  end

  return true
end

vim.keymap.set("n", "<leader>==", function()
  vim.lsp.buf.format({
    async = false,
    filter = M.format_filter,
  })
end, { desc = "LSP format buffer" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my.lsp", {}),
  callback = function(args)
    local ok, client = pcall(vim.lsp.get_client_by_id, args.data.client_id)
    if not ok or not client then
      return
    end
    if client:supports_method("textDocument/completion") then
      local chars = {}
      for i = 32, 126 do
        table.insert(chars, string.char(i))
      end
      local cap = client.server_capabilities.completionProvider
      if type(cap) == "table" then
        cap.triggerCharacters = chars
      end
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})

vim.cmd([[set completeopt+=menuone,noselect,popup]])

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    vim.lsp.buf.format({
      bufnr = args.buf,
      async = false,
      filter = function(client)
        return M.format_filter_for(args.buf, client)
      end,
    })
  end,
})

function M.apply_enable()
  project.detect()

  ---@type string[]
  local enabled = { "lua_ls" }

  if project.is_web then
    vim.list_extend(enabled, {
      "ts_ls",
      "eslint",
      "html",
      "cssls",
      "jsonls",
      "tailwindcss",
      "marksman",
      "vue_ls",
    })
  end

  if project.is_cpp then
    vim.list_extend(enabled, {
      "clangd",
      "cmake",
      "neocmake",
      "glsl_analyzer",
      "wgsl_analyzer",
    })
  end

  vim.lsp.enable(enabled)
end

return M
