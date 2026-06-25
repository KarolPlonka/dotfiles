vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("i", "<C-o>", "<Esc>oa")
vim.keymap.set("i", "<C-O>", "<Esc>Oa")

vim.keymap.set("n", "<leader>yy", '"+y')
vim.keymap.set("v", "<leader>yy", '"+y')
vim.keymap.set("n", "<leader>pp", '"+p')
vim.keymap.set("v", "<C-y>", '"+y')
vim.keymap.set("n", "<C-p>", '"+p')

vim.keymap.set("n", "<leader>dd", '"_dd')
vim.keymap.set("v", "<leader>d", '"_d')
vim.keymap.set("v", "p", '"_dP')

vim.keymap.set("v", "<leader>rr", '"hy:%s/<C-r>h//gc<left><left><left>')

vim.keymap.set("n", "<C-n>", "<C-^>")
vim.keymap.set("i", "<C-b>", "<C-w>")
vim.keymap.set("i", "<C-BS>", "<C-w>")

vim.keymap.set("n", "<leader>en", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>ep", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<leader>eg", vim.diagnostic.open_float)

vim.keymap.set("n", "<leader>rr", function()
  vim.lsp.stop_client(vim.lsp.get_clients())
  print("LSP servers restarted")
end)

vim.keymap.set("n", "<leader>cp", function()
  vim.fn.setreg("+", vim.fn.expand("%"))
  print("Copied: " .. vim.fn.expand("%"))
end, { desc = "Copy full file path" })
