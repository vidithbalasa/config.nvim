vim.lsp.config['pylsp'] = {
  -- Command to start server
  cmd = { 'pylsp' },
  -- cmd = { os.getenv("HOME") .. "/.local/uv-lsp-venv/bin/pylsp" },
  -- Filetypes to automatically attach to
  filetypes = { 'python' },
  -- Root directory markers for Python projects
  root_markers = {'.git', '.uv_venv'},
  -- Specific settings to send to the server
  settings = {
    pylsp = {
      python = {
        pythonPath = vim.fn.getcwd() .. "/.venv/bin/python"
      },
      plugins = {
        -- Linter options
        pycodestyle = {
          enabled = false
        },
        pylint = {
          enabled = true,
          args = {
            "--max-line-length=999",
            "--disable=missing-module-docstring",
            "--disable=wrong-import-order"
          }
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
          enabled = false
        }
      }
    }
  }
}

vim.lsp.enable('pylsp')
