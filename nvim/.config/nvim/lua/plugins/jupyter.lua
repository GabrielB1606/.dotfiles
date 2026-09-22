-- Python notebook support: jupytext (ipynb <-> markdown), molten (kernel exec),
-- image.nvim (inline matplotlib plots), quarto + otter (LSP inside cells)
local nvim_python = vim.fn.expand("~/.venvs/neovim/bin/python")

vim.g.python3_host_prog = nvim_python
vim.g.loaded_python_provider = 1

return {
  -- Open/save .ipynb as markdown
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    init = function()
      -- make sure the venv's jupytext CLI is on PATH
      local venv_bin = vim.fn.expand("~/.venvs/neovim/bin")
      if vim.fn.isdirectory(venv_bin) == 1 then
        vim.env.PATH = venv_bin .. ":" .. vim.env.PATH
      end
    end,
    opts = {
      custom_language_formatting = {
        python = {
          extension = "md",
          style = "markdown",
          force_ft = "markdown",
        },
      },
    },
  },

  -- Inline image rendering via kitty graphics protocol (works in ghostty).
  -- lazy = false: molten resolves the image provider when it initializes,
  -- so image.nvim must already be on the runtimepath at that point.
  {
    "3rd/image.nvim",
    lazy = false,
    opts = {
      backend = "kitty",
      integrations = {
        markdown = { enabled = true, filetypes = { "markdown", "vimwiki" } },
        neorg = { enabled = false },
      },
      max_width = 100,
      max_height_window_percentage = 50,
      window_overlap_clear_enabled = true,
      editor_only_render_when_focused = false,
      processor = "magick_cli",
      kitty_method = "normal",
    },
  },

  -- Jupyter kernel execution
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = {
      "3rd/image.nvim",
    },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_crop_border = true
      vim.g.molten_output_show_more = true
      vim.g.molten_output_win_border = { "", "━", "", "" }
      vim.g.molten_output_win_hide_on_leave = true
      vim.g.molten_output_win_style = false
      vim.g.molten_save_path = vim.fn.stdpath("data") .. "/molten"
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_text_max_lines = 12
      vim.g.molten_wrap_output = true

      -- jupyter_client needs its runtime dir to exist or kernel startup fails
      vim.fn.mkdir(vim.fn.expand("~/.local/share/jupyter/runtime"), "p")

      -- Init the buffer with the kernel from the notebook metadata, falling
      -- back to the venv / local venv name (canonical molten notebook setup)
      local function init_molten_buffer(e)
        vim.schedule(function()
          local kernels = vim.fn.MoltenAvailableKernels()
          local try_kernel_name = function()
            local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
            return metadata.kernelspec.name
          end
          local ok, kernel_name = pcall(try_kernel_name)
          if not ok or not vim.tbl_contains(kernels, kernel_name) then
            kernel_name = nil
            local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
            if venv ~= nil then
              kernel_name = string.match(venv, "/.+/(.+)")
            end
          end
          if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
            pcall(vim.cmd, ("MoltenInit %s"):format(kernel_name))
          end
          pcall(vim.cmd.MoltenImportOutput)
        end)
      end

      vim.api.nvim_create_autocmd("BufAdd", {
        pattern = { "*.ipynb" },
        callback = init_molten_buffer,
      })
      -- catch files opened like `nvim ./hi.ipynb`
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*.ipynb" },
        callback = function(e)
          if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
            init_molten_buffer(e)
          end
        end,
      })
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.ipynb" },
        callback = function()
          if require("molten.status").initialized() == "Molten" then
            vim.cmd("MoltenExportOutput!")
          end
        end,
      })
    end,
  },

  -- Quarto integration: run cells + otter LSP inside code cells
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "markdown", "qmd", "quarto", "ipynb" },
    opts = {
      debug = false,
      closePreviewOnExit = true,
      lspFeatures = {
        enabled = true,
        chunks = "curly",
        languages = { "r", "python", "julia", "bash", "html" },
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
        never_run = { "yaml" },
      },
    },
    config = function(_, opts)
      require("quarto").setup(opts)
      local runner = require("quarto.runner")
      vim.keymap.set("n", "<leader>nbr", runner.run_cell, { desc = "Run cell", silent = true })
      vim.keymap.set("n", "<leader>nbu", runner.run_above, { desc = "Run cell and above", silent = true })
      vim.keymap.set("n", "<leader>nbA", runner.run_all, { desc = "Run all cells", silent = true })
      vim.keymap.set("n", "<leader>nbl", runner.run_line, { desc = "Run line", silent = true })
      vim.keymap.set("v", "<leader>nbv", runner.run_range, { desc = "Run selection", silent = true })
    end,
  },

  -- Otter: LSP for code chunks in markdown buffers
  {
    "jmbuhr/otter.nvim",
    lazy = true,
    opts = {
      lsp = {
        hover = {
          border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        },
        diagnostic_update_events = { "BufWritePost" },
      },
      buffers = {
        set_filetype = false,
        write_to_disk = false,
      },
      handle_leading_whitespace = true,
    },
    config = function(_, opts)
      local otter = require("otter")
      otter.setup(opts)
      vim.api.nvim_create_autocmd("BufWinEnter", {
        pattern = { "*.md", "*.qmd", "*.ipynb" },
        callback = function()
          local ok, err = pcall(otter.activate)
          if not ok then
            vim.notify("Otter activation failed: " .. tostring(err), vim.log.levels.WARN)
          end
        end,
        group = vim.api.nvim_create_augroup("OtterActivate", { clear = true }),
      })
    end,
  },

  -- Which-key legend for the notebook group
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>n", group = "notebook/notifications" },
        { "<leader>nb", group = "notebook", icon = "󰠮" },
        { "<leader>nbA", desc = "Run all cells" },
        { "<leader>nbi", desc = "Init kernel" },
        { "<leader>nbd", desc = "Delete cell output" },
        { "<leader>nbe", desc = "Export outputs" },
        { "<leader>nbh", desc = "Hide output" },
        { "<leader>nbj", desc = "Next output cell" },
        { "<leader>nbk", desc = "Prev output cell" },
        { "<leader>nbl", desc = "Run line" },
        { "<leader>nbo", desc = "Show/enter output" },
        { "<leader>nbr", desc = "Run cell" },
        { "<leader>nbu", desc = "Run cell and above" },
        { "<leader>nbv", desc = "Run selection" },
        { "<leader>nbR", desc = "Restart kernel" },
        { "<leader>nbx", desc = "Interrupt kernel" },
        { "<leader>nn", desc = "Notification History" },
      },
    },
  },
}
