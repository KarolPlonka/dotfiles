local function nvm_node()
    local nvm_dir = vim.fn.expand("~/.nvm")
    local default_alias = nvm_dir .. "/alias/default"
    local f = io.open(default_alias, "r")
    if not f then return "node" end
    f:close()
    -- nvm alias "default" may point to a named alias (e.g. "node"), so pick the highest installed version
    local handle = io.popen("ls -d " .. nvm_dir .. "/versions/node/v* 2>/dev/null | sort -V | tail -1")
    if not handle then return "node" end
    local latest = handle:read("*l")
    handle:close()
    if latest and latest ~= "" then
        local bin = latest .. "/bin/node"
        if vim.fn.executable(bin) == 1 then return bin end
    end
    return "node"
end

return {
    {
        "zbirenbaum/copilot.lua",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                copilot_node_command = nvm_node(),
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
