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
-- Prevents word from staying highlighted even after search is complete
-- Press enter again after search to clear it

---- Plugins + Stuff ----
require("plugins")
require("ui") -- Small ui tweaks
require("lsp")

---- Key Binds ----
vim.api.nvim_set_keymap('n', '<leader>ff', ':MiniFinder<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show LSP diagnostics' })
vim.keymap.set('n', 'grn', vim.lsp.buf.rename, { noremap = true, silent = true, desc = "LSP: Rename symbol" })
vim.keymap.set('n','grr',vim.lsp.buf.references,{noremap=true,silent=true,desc="LSP: Show references"})
vim.keymap.set("n", "<CR>", "<CR>:nohlsearch<CR>", { silent = true })
local on_attach = function(client, bufnr)
  -- enable <C-x><C-o> completion from LSP
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- your other keymaps here
  -- e.g. vim.keymap.set('n','grn',vim.lsp.buf.rename, { buffer=bufnr, ... })
end

require('lspconfig').pyright.setup({
  on_attach = on_attach,
  -- ... any other settings ...
})

