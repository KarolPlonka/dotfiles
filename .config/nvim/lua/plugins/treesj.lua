return {
    {
        "Wansmer/treesj",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("treesj").setup({
                use_default_keymaps = false,
                max_join_length = 240,
            })
            vim.keymap.set("n", "<leader>j", require("treesj").toggle)
        end,
    },
}
