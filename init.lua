---- vim config ----
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.cursorline     = true
vim.opt.tabstop        = 4
vim.opt.shiftwidth     = 4
vim.opt.expandtab      = true
vim.g.mapleader        = " "
vim.cmd('colorscheme default')

---- key binds ----
-- mini finder
vim.api.nvim_set_keymap('n', '<leader>gf', ':MiniFinder<CR>', { noremap = true, silent = true })

---- *my* plugins ----
require("mini-finder").setup({
    height = 5,            -- Height of the finder window
    max_results = 3,       -- Maximum number of results to show
    prompt = "Find: ",     -- Prompt string for the search bar
    border = "rounded",    -- Border style for the window
    width = 0.5,           -- Width of the window (50% of editor width)
    position = "bottom",   -- Position of the window   
})

require("ui")
