---- Vim Config ----
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.cursorline     = true
vim.opt.tabstop        = 4
vim.opt.shiftwidth     = 4
vim.opt.expandtab      = true
vim.g.mapleader        = " "
vim.opt.signcolumn = "yes:2"  -- or "yes:2" if you want it wider
vim.cmd('syntax enable')
vim.cmd('set nowrap')
vim.cmd('colorscheme koehler')
vim.cmd('filetype plugin indent on')
vim.cmd('set iskeyword-=_')

---- Plugins + Stuff ----
require("plugins")
require("ui") -- Small ui tweaks
require("lsp")

---- Key Binds ----
vim.api.nvim_set_keymap('n', '<leader>ff', ':MiniFinder<CR>', { noremap = true, silent = true }) -- file finder
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float) -- Show error
vim.keymap.set("n", "<CR>", "<CR>:nohlsearch<CR>", { silent = true }) -- Unhighlight search
vim.api.nvim_set_keymap( "n", "<leader>lr", ":lua for _, client in pairs(vim.lsp.get_clients()) do client.request('shutdown', nil, function() client.notify('exit', nil) end) end vim.cmd('edit!')<CR>", { noremap = true, silent = true } )
