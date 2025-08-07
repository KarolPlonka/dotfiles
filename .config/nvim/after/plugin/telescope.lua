local telescope = require('telescope')
local builtin = require('telescope.builtin')
local actions = require("telescope.actions")
telescope.load_extension('live_grep_args')

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
	    ["<Esc>"] = actions.close,
      },
    },
  },
})

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fa', function()
  builtin.find_files({
    hidden = true,
    no_ignore = true,
    no_ignore_parent = true,
    file_ignore_patterns = {
      "^.venv/",
      "^node_modules/",
      "^.git/",
    }
  })
end, { desc = "Find all files (including hidden, exclude certain dirs)" })

vim.keymap.set("n", "<leader>gs", builtin.live_grep, {})

vim.keymap.set('n', '<leader>ga', function()
  builtin.live_grep({
    additional_args = function()
      return { 
        "--hidden", 
        "--no-ignore", 
        "--glob", "!.venv/**",
        "--glob", "!node_modules/**",
        "--glob", "!.git/**"
      }
    end
  })
end, { desc = "Grep all files (including hidden, exclude certain dirs)" })

local function search_visual_selection()
  -- Save current register
  local saved_reg = vim.fn.getreg('"')
  local saved_regtype = vim.fn.getregtype('"')
  
  -- Yank visual selection to unnamed register
  vim.cmd('normal! "vy')
  
  -- Get the yanked text and strip newlines
  local search_term = vim.fn.getreg('"'):gsub('\n', '')
  
  -- Restore register
  vim.fn.setreg('"', saved_reg, saved_regtype)
  
  -- Search with Telescope live_grep
  require('telescope.builtin').live_grep({
    default_text = search_term
  })
end

-- Bind <leader>gs in visual mode
vim.keymap.set('v', '<leader>gs', search_visual_selection, {})
