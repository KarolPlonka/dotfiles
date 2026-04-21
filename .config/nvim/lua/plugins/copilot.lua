return {
    {
        "zbirenbaum/copilot.lua",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    keymap = {
                        accept = "<Tab>",
                        accept_word = "<C-l>",
                        next = "<C-N>",
                        prev = "<C-P>",
                        dismiss = "<C-X>",
                    },
                },
                panel = { enabled = false },
            })
            vim.keymap.set("i", "<C-c>", function()
                require("copilot.suggestion").dismiss()
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
            end)
        end,
    },
}
