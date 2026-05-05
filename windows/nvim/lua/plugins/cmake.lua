require("cmake-tools").setup({
  cmake_use_preset = true,
  -- cmake-tools.nvim uses backslash paths in autocmd patterns on Windows (bug), which triggers E65.
  cmake_regenerate_on_save = false,
  cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
  cmake_build_directory = "build",
  cmake_compile_commands_options = {
    action = "none",
  },
  cmake_executor = {
    name = "quickfix",
    opts = {},
  },
  cmake_runner = {
    name = "terminal",
    opts = {},
  },
})

local function cmake_cmd(name)
  return function()
    vim.cmd(name)
  end
end

vim.keymap.set("n", "<leader>bb", cmake_cmd("CMakeBuild"), { desc = "CMake: build" })
vim.keymap.set("n", "<leader>bR", cmake_cmd("CMakeBuild!"), { desc = "CMake: clean build" })
vim.keymap.set("n", "<leader>bc", cmake_cmd("CMakeGenerate"), { desc = "CMake: configure" })
vim.keymap.set("n", "<leader>bC", cmake_cmd("CMakeGenerate!"), { desc = "CMake: clean configure" })
vim.keymap.set("n", "<leader>bx", cmake_cmd("CMakeClean"), { desc = "CMake: clean build tree" })
vim.keymap.set("n", "<leader>bk", function()
  local ok, cmake = pcall(require, "cmake-tools")
  if ok and cmake.has_cmake_preset() then
    vim.cmd("CMakeSelectConfigurePreset")
  else
    vim.cmd("CMakeSelectKit")
  end
end, { desc = "CMake: toolchain (configure preset or kit)" })
vim.keymap.set("n", "<leader>bs", cmake_cmd("CMakeSelectBuildPreset"), { desc = "CMake: select build preset" })
vim.keymap.set("n", "<leader>br", cmake_cmd("CMakeRun"), { desc = "CMake: run launch target" })
vim.keymap.set("n", "<leader>bd", cmake_cmd("CMakeDebug"), { desc = "CMake: debug launch target" })
vim.keymap.set("n", "<leader>bt", cmake_cmd("CMakeSelectBuildTarget"), { desc = "CMake: select build target" })
vim.keymap.set("n", "<leader>bl", cmake_cmd("CMakeSelectLaunchTarget"), { desc = "CMake: select launch target" })
vim.keymap.set("n", "<leader>bT", cmake_cmd("CMakeSelectBuildType"), { desc = "CMake: select build type" })
vim.keymap.set("n", "<leader>ba", cmake_cmd("CMakeLaunchArgs"), { desc = "CMake: launch arguments" })
vim.keymap.set("n", "<leader>bp", cmake_cmd("CMakeSelectCwd"), { desc = "CMake: project root (CMakeLists dir)" })
vim.keymap.set("n", "<leader>bi", cmake_cmd("CMakeInstall"), { desc = "CMake: install" })
vim.keymap.set("n", "<leader>bS", cmake_cmd("CMakeSettings"), { desc = "CMake: settings" })
