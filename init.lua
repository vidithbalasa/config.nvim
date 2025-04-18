---- Vim Config ----
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.cursorline     = true
vim.opt.tabstop        = 4
vim.opt.shiftwidth     = 4
vim.opt.expandtab      = true
vim.g.mapleader        = " "
vim.cmd('syntax enable')
vim.opt.syntax         = "on"
vim.cmd('colorscheme koehler')
vim.cmd('filetype plugin indent on')

---- Plugins + Stuff ----
require("plugins")
require("ui") -- Small ui tweaks
require("lsp")

---- Key Binds ----
vim.api.nvim_set_keymap('n', '<leader>ff', ':MiniFinder<CR>', { noremap = true, silent = true })
