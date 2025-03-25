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
vim.keymap.set('n', '<leader>gf', builtin.git_files, {})
vim.keymap.set("n", "<leader>gs", builtin.live_grep, {})
