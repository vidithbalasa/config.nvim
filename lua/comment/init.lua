-- Function to toggle comments
function toggle_comment()
  local comment_map = {
    lua = '--',
    python = '#',
    javascript = '//',
    typescript = '//',
    javascriptreact = '//',
    typescriptreact = '//',
    c = '//',
    cpp = '//',
    java = '//',
    rust = '//',
    go = '//',
    sh = '#',
    bash = '#',
    conf = '#',
    vim = '"',
    yaml = '#',
    markdown = '<!--',
    html = '<!--',
    css = '/*',
    -- Added Terraform and HCL support
    terraform = '#',
    tf = '#',
    hcl = '#',
  }
  
  local filetype = vim.bo.filetype
  local comment_str = comment_map[filetype] or '#'
  local end_str = ""
  
  -- Set end strings for specific filetypes
  if filetype == "html" or filetype == "markdown" then
    end_str = " -->"
  elseif filetype == "css" then
    end_str = " */"
  end
  
  -- Get cursor position
  local line = vim.fn.line('.')
  local content = vim.fn.getline(line)
  
  -- Check if line is already commented
  local is_commented = vim.fn.stridx(vim.fn.trim(content), comment_str) == 0
  
  if is_commented then
    -- Uncomment: remove comment string
    local new_content
    if end_str ~= "" then
      new_content = content:gsub("^%s*" .. vim.pesc(comment_str) .. "(.-)" .. vim.pesc(end_str) .. "%s*$", "%1")
    else
      new_content = content:gsub("^%s*" .. vim.pesc(comment_str) .. "%s?", "")
    end
    vim.fn.setline(line, new_content)
  else
    -- Comment: add comment string
    local new_content = comment_str .. " " .. content .. end_str
    vim.fn.setline(line, new_content)
  end
end

-- Visual mode toggle comment function
function toggle_comment_visual()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  
  for i = start_line, end_line do
    -- Store cursor position
    local curr_pos = vim.fn.getpos('.')
    
    -- Move to each line and toggle comment
    vim.fn.setpos('.', {0, i, 1, 0})
    toggle_comment()
    
    -- Restore cursor position
    vim.fn.setpos('.', curr_pos)
  end
end

-- Normal mode mappings
vim.keymap.set('n', '<C-/>', toggle_comment, { noremap = true, silent = true })
vim.keymap.set('n', '<C-_>', toggle_comment, { noremap = true, silent = true })

-- Visual mode mappings
vim.keymap.set('x', '<C-/>', ':<C-u>lua toggle_comment_visual()<CR>gv', { noremap = true, silent = true })
vim.keymap.set('x', '<C-_>', ':<C-u>lua toggle_comment_visual()<CR>gv', { noremap = true, silent = true })
