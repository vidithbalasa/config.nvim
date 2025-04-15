vim.lsp.config['pylsp'] = {
  -- Command to start server
  -- cmd = { 'pylsp' },
  cmd = { os.getenv("HOME") .. "/.local/uv-lsp-venv/bin/pylsp" },
  -- Filetypes to automatically attach to
  filetypes = { 'python' },
  -- Root directory markers for Python projects
  root_markers = {'.git', '.uv_venv'},
  -- Specific settings to send to the server
  settings = {
    pylsp = {
      plugins = {
        -- Linter options
        pycodestyle = {
          enabled = true,
          maxLineLength = 100
        },
        pylint = {
          enabled = true
        },
        -- Formatter options
        black = {
          enabled = true
        },
        autopep8 = {
          enabled = false
        },
        yapf = {
          enabled = false
        },
        -- Type checker
        pylsp_mypy = {
          enabled = true
        },
        -- Auto-completion options
        jedi_completion = {
          enabled = true,
          fuzzy = true
        },
        -- Import sorting
        pyls_isort = {
          enabled = true
        }
      }
    }
  }
}

vim.lsp.enable('pylsp')
