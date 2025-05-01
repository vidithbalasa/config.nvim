vim.lsp.config['terragrunt_ls'] = {
  cmd = { 'terragrunt-ls', 'serve' },
  filetypes = { 'hcl', 'terragrunt' },
  root_markers = {'.git', '.uv_venv'},
}

vim.lsp.enable('terragrunt_ls')
