vim.keymap.set("i", "<C-L>", "<Plug>(copilot-accept-word)")
vim.keymap.set("i", "<C-K>", "<Plug>(copilot-accept-line)")

vim.keymap.set("n", "<C-X>", "<Plug>(copilot-dismiss)")
vim.keymap.set("i", "<C-X>", "<Plug>(copilot-dismiss)")

vim.keymap.set("i", "<C-N>", "<Plug>(copilot-next)")
vim.keymap.set("i", "<C-P>", "<Plug>(copilot-previous)")

vim.keymap.set("i", "<C-S>", "<Plug>(copilot-suggest)")

 -- reset with leader rc
vim.keymap.set("n", "<leader>rc", function()
    vim.cmd("Copilot restart")
    vim.notify("Copilot restarted", vim.log.levels.INFO)
end, { desc = "Copilot: Reconfigure" })


