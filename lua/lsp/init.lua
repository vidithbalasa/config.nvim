require("lsp.lua_ls")
require("lsp.python_ls")

-- Runs `:edit` when opening a new buffer
-- Hacky fix bc for some reason neovim is making me do that
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        vim.cmd("silent! e")
    end,
})
