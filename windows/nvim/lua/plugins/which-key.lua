local M = {}

function M.setup()
  local project = require("project")
  project.detect()

  local wk = require("which-key")

  local spec = {
    { "<leader>a", group = "AI" },
    { "<leader>f", group = "search" },
    { "<leader>g", group = "git" },
    { "<leader>x", group = "diagnostics/debug" },
    { "<leader>=", group = "format" },
  }

  if project.is_cpp then
    table.insert(spec, { "<leader>b", group = "cmake" })
  end

  if project.is_web then
    table.insert(spec, { "<leader>n", group = "web/bun" })
  end

  wk.add(spec)
end

return M
