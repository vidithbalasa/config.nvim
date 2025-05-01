vim.lsp.config['terraformls'] = {
  -- Command and arguments to start the server
  cmd = { 'terraform-ls', 'serve' },
  -- Filetypes to automatically attach to
  filetypes = { 'terraform', 'tf', 'terraform-vars', 'hcl' },
  -- Sets the "root directory" to the parent directory of the file in the
  -- current buffer that contains either a ".terraform" directory or
  -- "terraform.tfstate" file
  root_markers = { '.terraform', 'terraform.tfstate', '.git' },

  settings = {
    terraform = {
      -- Enable terraform fmt on save
      formatOnSave = true,
      -- Enable terraform validation on save
      validateOnSave = true,
      -- Path to terraform binary
      terraformExecPath = 'terraform',
      -- Path to terraform workspace
      terraformWorkspace = '',
      -- Enable experimental features
      experimentalFeatures = {
        validateOnSave = true,
        prefillRequiredFields = true
      }
    }
  }
}

vim.lsp.enable('terraformls')
