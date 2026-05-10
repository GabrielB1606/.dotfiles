local M = {}

local project = require("project")

require("mason").setup({
  ui = { border = "rounded" },
})

function M.ensure_tooling()
  project.detect()

  ---@type string[]
  local servers = { "lua_ls" }

  if project.is_web then
    vim.list_extend(servers, {
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
    vim.list_extend(servers, {
      "clangd",
      "cmake",
      "neocmake",
      "glsl_analyzer",
      "wgsl_analyzer",
    })
  end

  require("mason-lspconfig").setup({
    ensure_installed = servers,
    automatic_enable = false,
  })

  --- Mason package names (non-LSP); integrations allow lsp/dap names where supported.
  ---@type string[]
  local tools = {}

  if project.is_web then
    vim.list_extend(tools, { "prettierd", "eslint_d" })
  end

  if project.is_cpp then
    vim.list_extend(tools, { "clang-format", "codelldb" })
  end

  require("mason-tool-installer").setup({
    ensure_installed = tools,
    run_on_start = #tools > 0,
    auto_update = false,
    integrations = {
      ["mason-lspconfig"] = true,
      ["mason-null-ls"] = false,
      ["mason-nvim-dap"] = true,
    },
  })
end

return M
