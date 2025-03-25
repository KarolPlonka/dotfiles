vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("i", "<C-o>", "<Esc>oa")
vim.keymap.set("i", "<C-O>", "<Esc>Oa")
vim.keymap.set("n", "<leader>cc", ":CommentToggle<CR>")

vim.keymap.set("n", "<leader>yy", '"+y')
vim.keymap.set("v", "<leader>yy", '"+y')
vim.keymap.set("n", "<leader>pp", '"+p')

vim.keymap.set("n", "<leader>dd", "\"_dd")
vim.keymap.set("v", "<leader>d", "\"_d")

vim.keymap.set("v", "<leader>rr", "\"hy:%s/<C-r>h//gc<left><left><left>" )

-- paste without yanking
vim.keymap.set("v", "p", "\"_dP")

vim.keymap.set("n", "<C-n>", "<C-^>")

vim.keymap.set("i", "<C-b>", "<C-w>")

vim.keymap.set("v", "<C-y>", '"+y')
vim.keymap.set("n", "<C-p>", '"+p')

-- ctrl + backspace in insert mode to delete word
vim.keymap.set("i", "<C-BS>", "<C-w>")

