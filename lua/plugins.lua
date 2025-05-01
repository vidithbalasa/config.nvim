---- Mini Finder ----
--[[
Creation Date: 4/14/25
Desc: A minimal replacement for telescope (git only). Lets you find and open files within your git project.
]]
require("mini-finder").setup({
    height = 5,            -- Height of the finder window
    max_results = 3,       -- Maximum number of results to show
    prompt = "Find: ",     -- Prompt string for the search bar
    border = "rounded",    -- Border style for the window
    width = 0.5,           -- Width of the window (50% of editor width)
    position = "bottom",   -- Position of the window   
})

---- TreeSitter ----
require('nvim-treesitter.configs').setup {
    ensure_installed = { "lua" },
    highlight = {
        enable = true,
    },
    auto_install = true,
}

require('lean').setup{ mappings = true }
