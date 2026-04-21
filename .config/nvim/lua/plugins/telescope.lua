return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          preview = { treesitter = false },
          get_status_text = function() return "" end,
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<Esc>"] = actions.close,
            },
          },
        },
      })

      telescope.load_extension("live_grep_args")

      -- hide statusline while telescope is open, restore on close
      vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopeFindPre",
        callback = function()
          vim.opt.laststatus = 0
        end,
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "TelescopePrompt",
        callback = function()
          vim.api.nvim_create_autocmd("BufWinLeave", {
            buffer = 0,
            once = true,
            callback = function()
              vim.opt.laststatus = 3
            end,
          })
        end,
      })
    end,
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
      {
        "<leader>fa",
        function()
          require("telescope.builtin").find_files({
            hidden = true,
            no_ignore = true,
            no_ignore_parent = true,
            file_ignore_patterns = { "^.venv/", "^node_modules/", "^.git/" },
          })
        end,
        desc = "Find all files (incl. hidden)",
      },
      { "<leader>gs", function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
      {
        "<leader>gs",
        function()
          local saved_reg = vim.fn.getreg('"')
          local saved_regtype = vim.fn.getregtype('"')
          vim.cmd('normal! "vy')
          local search_term = vim.fn.getreg('"'):gsub('\n', '')
          vim.fn.setreg('"', saved_reg, saved_regtype)
          require("telescope.builtin").live_grep({ default_text = search_term })
        end,
        mode = "v",
        desc = "Grep visual selection",
      },
      {
        "<leader>ga",
        function()
          require("telescope.builtin").live_grep({
            additional_args = function()
              return {
                "--hidden", "--no-ignore",
                "--glob", "!.venv/**",
                "--glob", "!node_modules/**",
                "--glob", "!.git/**",
              }
            end,
          })
        end,
        desc = "Grep all files (incl. hidden)",
      },
    },
  },
}
