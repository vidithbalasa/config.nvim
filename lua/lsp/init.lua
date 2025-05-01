require("lsp.lua_ls")
require("lsp.python_ls")
require("lsp.terraform_ls")
require("lsp.terragrunt_ls")

-- Runs `:edit` when opening a new buffer
-- Hacky fix bc for some reason neovim is making me do that
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        vim.cmd("silent! e")
    end,
})
