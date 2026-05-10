local dap = require("dap")
local dapui = require("dapui")

-- Breakpoint sign: red dot instead of B
vim.fn.sign_define("DapBreakpoint", { text = " ●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = " ●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e06c75" })

-- Setup nvim-dap-ui
dapui.setup()

-- Automatically open and close dap-ui when debugging
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

-- Keymaps for debugging
vim.keymap.set("n", "<leader>xr", function()
  dap.continue()
end, { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<leader>xo", function()
  dap.step_over()
end, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<leader>xi", function()
  dap.step_into()
end, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<leader>xO", function()
  dap.step_out()
end, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>xb", function()
  dap.toggle_breakpoint()
end, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>xB", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Set Conditional Breakpoint" })

--- Resolve CodeLLDB installed by Mason.
local function mason_codelldb_executable()
  local ok_reg, reg = pcall(require, "mason-registry")
  if not ok_reg or type(reg.get_package) ~= "function" then
    return nil
  end
  pcall(function()
    if reg.refresh then
      reg.refresh()
    end
  end)
  local ok_pkg, pkg = pcall(reg.get_package, "codelldb")
  if not ok_pkg or not pkg then
    return nil
  end
  local ok_installed, installed = pcall(function()
    return pkg:is_installed()
  end)
  if not ok_installed or not installed then
    return nil
  end
  local ok_path, root = pcall(function()
    return pkg:get_install_path()
  end)
  if not ok_path or type(root) ~= "string" or root == "" then
    return nil
  end
  local exe = vim.fs.joinpath(root, "extension", "adapter", "codelldb.exe")
  if vim.fn.filereadable(exe) == 1 then
    return exe
  end
  -- Some Mason layouts use POSIX-style layout on disk; fallback.
  exe = vim.fs.joinpath(root, "extension", "adapter", "codelldb")
  if vim.fn.filereadable(exe) == 1 then
    return exe
  end
  return nil
end

local function build_codelldb_adapter()
  local cmd = mason_codelldb_executable()
  if cmd then
    return {
      type = "server",
      port = "${port}",
      executable = {
        command = cmd,
        args = { "--port", "${port}" },
        detached = false,
      },
    }
  end
  vim.schedule(function()
    vim.notify(
      "codelldb not found. Install via :Mason (package `codelldb`) for C++ debugging.",
      vim.log.levels.WARN
    )
  end)
  return {
    type = "server",
    port = "${port}",
    executable = {
      command = "codelldb",
      args = { "--port", "${port}" },
      detached = false,
    },
  }
end

dap.adapters.codelldb = build_codelldb_adapter()

dap.configurations.cpp = {
  {
    name = "Compile & Debug C++ file",
    type = "codelldb",
    request = "launch",
    program = function()
      if vim.fn.executable("g++") ~= 1 then
        vim.notify("g++ not found on PATH.", vim.log.levels.ERROR)
        return nil
      end
      local file = vim.fn.expand("%:p")
      local out = vim.fn.expand("%:p:r") .. ".exe"

      vim.notify("Compiling " .. file .. " with g++...", vim.log.levels.INFO)
      local cmd = string.format('g++ -g "%s" -o "%s"', file, out)
      vim.fn.system(cmd)
      if vim.v.shell_error ~= 0 then
        vim.notify("Compilation failed.", vim.log.levels.ERROR)
        return nil
      end
      vim.notify("Starting debugger…", vim.log.levels.INFO)
      return out
    end,
    cwd = function()
      return vim.fn.expand("%:p:h")
    end,
    stopOnEntry = false,
    terminal = "integrated",
  },
  {
    name = "Debug existing executable",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = function()
      return vim.fn.expand("%:p:h")
    end,
    stopOnEntry = false,
    terminal = "integrated",
  },
  {
    name = "Debug CMake build output (pick .exe)",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
    end,
    cwd = function()
      return vim.fn.getcwd()
    end,
    stopOnEntry = false,
    terminal = "integrated",
  },
}

dap.configurations.c = dap.configurations.cpp
