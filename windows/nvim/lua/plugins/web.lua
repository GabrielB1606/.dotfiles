  extension = {
    mdx = "markdown",
  },
  filename = {
    ["slides.md"] = "markdown",
  },
})

local function has_slidev_deps()
  local root = require("project").root
  local pj = root .. "/package.json"
  if vim.fn.filereadable(pj) ~= 1 then
    return false
  end
  local ok, lines = pcall(vim.fn.readfile, pj)
  if not ok or not lines then
    return false
  end
  local text = vim.fn.join(lines, "\n")
  local dec_ok, data = pcall(vim.json.decode, text)
  if not dec_ok or type(data) ~= "table" then
    return false
  end
  local function scan(section)
    if type(section) ~= "table" then
      return false
    end
    return section["@slidev/cli"] ~= nil or section["slidev"] ~= nil
  end
  return scan(data.dependencies) or scan(data.devDependencies)
end

local function bun_run(script)
  return function()
    vim.cmd.vsplit()
    vim.cmd.term("bun run " .. script)
  end
end

vim.keymap.set("n", "<leader>nr", bun_run("dev"), { desc = "Bun: run dev" })
vim.keymap.set("n", "<leader>nb", bun_run("build"), { desc = "Bun: run build" })
vim.keymap.set("n", "<leader>nt", bun_run("test"), { desc = "Bun: run test" })

vim.keymap.set("n", "<leader>ns", function()
  if has_slidev_deps() or vim.fn.filereadable(require("project").root .. "/slides.md") == 1 then
    vim.cmd.vsplit()
    vim.cmd.term("bunx slidev")
  else
    vim.notify("Not a Slidev project (no slides.md / @slidev/cli)", vim.log.levels.WARN)
  end
end, { desc = "Slidev: bunx slidev" })
