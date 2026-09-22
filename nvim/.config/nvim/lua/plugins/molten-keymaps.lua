return {
  {
    "benlubas/molten-nvim",
    keys = {
      {
        "<leader>nbi",
        function()
          local kernels = vim.fn.MoltenAvailableKernels()
          if vim.tbl_contains(kernels, "python3") then
            vim.cmd.MoltenInit({ args = { "python3" } })
          else
            -- no python3 kernelspec: let molten prompt for a kernel
            vim.cmd.MoltenInit()
          end
        end,
        desc = "Init kernel",
        silent = true,
      },
      { "<leader>nbo", ":noautocmd MoltenEnterOutput<CR>", desc = "Show/enter output", silent = true },
      { "<leader>nbh", ":MoltenHideOutput<CR>", desc = "Hide output", silent = true },
      { "<leader>nbd", ":MoltenDelete<CR>", desc = "Delete cell output", silent = true },
      { "<leader>nbj", ":MoltenNext<CR>", desc = "Next output cell", silent = true },
      { "<leader>nbk", ":MoltenPrev<CR>", desc = "Prev output cell", silent = true },
      { "<leader>nbx", ":MoltenInterrupt<CR>", desc = "Interrupt kernel", silent = true },
      { "<leader>nbR", ":MoltenRestart!<CR>", desc = "Restart kernel", silent = true },
      { "<leader>nbe", ":MoltenExportOutput!<CR>", desc = "Export outputs to notebook", silent = true },
    },
  },
}
