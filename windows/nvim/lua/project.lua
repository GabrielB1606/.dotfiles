--[[
  Workspace roots and flags derived from cwd / nvim argv / current buffer path.
]]

local M = {}

---@type string
M.root = vim.fn.getcwd()

---@type boolean
M.is_web = false

---@type boolean
M.is_cpp = false

local WEB_MARKER_NAMES = {
  "package.json",
  "bun.lock",
  "bun.lockb",
  "next.config.js",
  "next.config.mjs",
  "next.config.ts",
  "slidev.config.ts",
  "slides.md",
}

local WEB_DEPS_HINTS = {
  next = true,
  react = true,
  ["@slidev/cli"] = true,
  slidev = true,
  vite = true,
  typescript = true,
  tailwindcss = true,
  eslint = true,
}

local CPP_ROOT_MARKERS = {
  "CMakeLists.txt",
  "CMakePresets.json",
  "CMakeUserPresets.json",
  "compile_commands.json",
}

local CPP_FILE_EXT = {
  cpp = true,
  cc = true,
  cxx = true,
  c = true,
  h = true,
  hpp = true,
  hh = true,
  inl = true,
  hlsl = true,
  glsl = true,
  vert = true,
  frag = true,
  wgsl = true,
}

local function dirname(path)
  if not path or path == "" then
    return vim.fn.getcwd()
  end
  return vim.fs.dirname(path) ---@type string
end

local function normalize_path_sep(p)
  return (p or ""):gsub("\\", "/")
end

local function fs_exists(path)
  return path ~= nil and path ~= "" and (vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1)
end

--- Directory to anchor root detection (prefer explicit nvim argv, then current buffer file).
local function get_start_dir()
  if vim.fn.argc() > 0 then
    local f = vim.fn.argv(0)
    local ok, rp = pcall(vim.fs.realpath, f)
    f = ok and rp or f
    if vim.fn.isdirectory(f) == 1 then
      return normalize_path_sep(f)
    end
    if vim.fn.filereadable(f) == 1 then
      return normalize_path_sep(dirname(f))
    end
  end
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  if name ~= "" and fs_exists(name) then
    local ok, rp = pcall(vim.fs.realpath, name)
    name = ok and rp or name
    if vim.fn.isdirectory(name) == 1 then
      return normalize_path_sep(name)
    end
    return normalize_path_sep(dirname(name))
  end
  return normalize_path_sep(vim.fn.getcwd())
end

local function resolve_abs(path)
  if not path then
    return nil
  end
  local full = vim.fn.fnamemodify(path, ":p")
  local ok, norm = pcall(vim.fs.normalize, full)
  local abs = ok and norm or full
  return normalize_path_sep(abs)
end

local function has_marker_in_dir(dir_abs, filenames)
  local d = dir_abs
  for _, fname in ipairs(filenames) do
    local p = d .. "/" .. fname
    if vim.fn.filereadable(p) == 1 then
      return true
    end
  end
  return false
end

local function read_package_json_signals(root_abs)
  local pj = root_abs .. "/package.json"
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
  local function scan_section(section)
    if type(section) ~= "table" then
      return false
    end
    for k in pairs(section) do
      if WEB_DEPS_HINTS[k] then
        return true
      end
    end
    return false
  end
  return scan_section(data.dependencies) or scan_section(data.devDependencies)
end

local function is_cpp_file_path(abs_path)
  if not abs_path or abs_path == "" then
    return false
  end
  local base = vim.fn.fnamemodify(abs_path, ":t"):lower()
  local ext = base:match("%.([^%.]+)$")
  return ext ~= nil and CPP_FILE_EXT[ext] == true
end

local function has_cpp_hints_in_tree(root_abs, max_depth)
  max_depth = max_depth or 2
  root_abs = normalize_path_sep(root_abs)

  ---@param dir string
  ---@param depth integer
  local function walk(dir, depth)
    if depth > max_depth then
      return false
    end
    local ok, entries = pcall(vim.fs.dir, dir)
    if not ok or not entries then
      return false
    end
    for name, t in entries do
      if name ~= "." and name ~= ".." then
        local ext = name:match("%.([^%.]+)$")
        if ext and CPP_FILE_EXT[ext:lower()] then
          return true
        end
        if t == "directory" and depth < max_depth then
          if name ~= "node_modules" and name ~= ".git" and name ~= "build" and name ~= "out" then
            if walk(normalize_path_sep(dir .. "/" .. name), depth + 1) then
              return true
            end
          end
        end
      end
    end
    return false
  end
  return walk(root_abs, 0)
end

--- Pick unified project root when web and cpp disagree.
local function choose_root(web_r, cpp_r, start_dir)
  if web_r and cpp_r then
    local wr = resolve_abs(web_r)
    local cr = resolve_abs(cpp_r)
    if wr and cr then
      local w_under_c = vim.startswith(wr, cr .. "/") or wr == cr
      local c_under_w = vim.startswith(cr, wr .. "/") or cr == wr
      if w_under_c and not c_under_w then
        return wr
      end
      if c_under_w and not w_under_c then
        return cr
      end
    end
    return wr or cr or start_dir
  end
  return resolve_abs(web_r or cpp_r or start_dir) or start_dir
end

function M.detect()
  local start_dir = get_start_dir()

  ---@diagnostic disable-next-line: param-type-mismatch
  local web_root_rel = vim.fs.root(start_dir, WEB_MARKER_NAMES) ---@type string|nil

  local cpp_marker_list = vim.list_extend({ ".clangd" }, CPP_ROOT_MARKERS)
  ---@diagnostic disable-next-line: param-type-mismatch
  local cpp_root_rel = vim.fs.root(start_dir, cpp_marker_list) ---@type string|nil

  M.root = choose_root(web_root_rel, cpp_root_rel, start_dir)

  local root_abs = resolve_abs(M.root) or M.root

  -- Web
  M.is_web = web_root_rel ~= nil
    or has_marker_in_dir(root_abs, WEB_MARKER_NAMES)
    or read_package_json_signals(root_abs)
  if vim.fn.filereadable(root_abs .. "/slides.md") == 1 then
    local slidev_head = vim.fn.readfile(root_abs .. "/slides.md", "", 80)
    if slidev_head and type(slidev_head) == "table" then
      local head = vim.fn.join(slidev_head, "\n"):lower()
      if head:find("slidev", 1, true) or vim.fn.isdirectory(root_abs .. "/slides") == 1 then
        M.is_web = true
      end
    end
    if read_package_json_signals(root_abs) then
      M.is_web = true
    end
  end

  -- C++
  M.is_cpp = cpp_root_rel ~= nil
    or has_marker_in_dir(root_abs, CPP_ROOT_MARKERS)
    or vim.fn.filereadable(root_abs .. "/.clangd") == 1

  local focus_path = nil
  if vim.fn.argc() > 0 then
    focus_path = vim.fn.argv(0)
  else
    local n = vim.api.nvim_buf_get_name(0)
    if n ~= "" then
      focus_path = n
    end
  end
  if focus_path and focus_path ~= "" then
    local ok_rp, rp = pcall(vim.fs.realpath, focus_path)
    focus_path = ok_rp and rp or focus_path
    focus_path = resolve_abs(focus_path) or focus_path
    if is_cpp_file_path(focus_path) then
      M.is_cpp = true
    end
  end

  if not M.is_cpp then
    M.is_cpp = has_cpp_hints_in_tree(root_abs, 2)
  end

  return M
end

local detect_pending
local function schedule_detect()
  if detect_pending then
    return
  end
  detect_pending = true
  vim.defer_fn(function()
    detect_pending = false
    M.detect()
  end, 120)
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    M.detect()
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
  callback = function()
    schedule_detect()
  end,
})

M.detect()

return M
