local project = require("project")

vim.lsp.config("clangd", {
  before_init = function(_, client_config)
    local ok, cmake = pcall(require, "cmake-tools")
    if ok then
      cmake.clangd_on_new_config(client_config)
    end
  end,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
    "--compile-commands-dir=build",
    "--query-driver=D:/dev/mingw64/bin/*.exe",
    "--query-driver=C:/Program Files/LLVM/bin/*.exe",
    "--query-driver=C:/Program Files/Microsoft Visual Studio/*/*/VC/Tools/MSVC/*/bin/Hostx64/x64/*.exe",
    "--query-driver=C:/Program Files/Microsoft Visual Studio/*/*/VC/Tools/MSVC/*/bin/Hostx64/x86/*.exe",
  },
  init_options = {
    fallbackFlags = {
      "-target",
      "x86_64-w64-mingw32",
    },
  },
})

require("plugins.cmake")
require("plugins.dap")
