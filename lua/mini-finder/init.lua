-- mini-finder.lua
-- A minimal file finder for Neovim that searches through all Git-tracked files
-- Shows a search bar at the bottom with top 3 results below it

local M = {}
local api = vim.api

-- Default configuration
M.config = {
  height = 5,            -- Height of the finder window (lines)
  max_results = 3,       -- Maximum number of results to show
  prompt = "Search: ",   -- Prompt string for the search bar
}

-- Store the current state
local state = {
  buf = nil,             -- Buffer ID for the finder window
  win = nil,             -- Window ID for the finder window
  files = {},            -- List of files to search through
  git_root = "",         -- Git repository root directory
  pattern = "",          -- Current search pattern
  selected_index = 0,    -- Currently selected result index (0 means input line)
  original_dir = "",     -- Original directory before changing to git root
}

-- Get all git-tracked files in the repository
local function get_git_files()
  local files = {}
  
  -- Save the original directory
  state.original_dir = vim.fn.getcwd()
  
  -- Check if we're in a git repository
  local is_git_repo = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    -- Not a git repo, fallback to regular file search
    print("Not a git repository. Falling back to regular file search.")
    return scan_dir(state.original_dir)
  end
  
  -- Get the git root directory
  state.git_root = vim.fn.trim(vim.fn.system("git rev-parse --show-toplevel"))
  
  -- Change to git root directory for proper file listing
  vim.cmd("cd " .. vim.fn.fnameescape(state.git_root))
  
  -- Get all tracked files using git ls-files
  local handle = io.popen("git ls-files")
  if handle then
    for file in handle:lines() do
      -- Add the file to our list (relative to git root)
      table.insert(files, file)
    end
    handle:close()
  end
  
  -- If there are no git tracked files, fall back to regular file search
  if #files == 0 then
    print("No git tracked files found. Falling back to regular file search.")
    return scan_dir(state.original_dir)
  end
  
  return files
end

-- Function to recursively scan directory for files (fallback if git not available)
local function scan_dir(dir, file_list)
  file_list = file_list or {}
  
  -- Skip some directories like .git, node_modules, etc.
  local basename = vim.fn.fnamemodify(dir, ":t")
  if basename == ".git" or basename == "node_modules" then
    return file_list
  end
  
  local handle = vim.loop.fs_scandir(dir)
  if not handle then return file_list end

  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then break end
    
    -- Skip hidden files/folders
    if name:sub(1, 1) ~= "." then
      local full_path = dir .. '/' .. name
      
      if type == 'file' then
        -- Make path relative to cwd for cleaner display
        local rel_path = vim.fn.fnamemodify(full_path, ":.")
        table.insert(file_list, rel_path)
      elseif type == 'directory' then
        scan_dir(full_path, file_list)
      end
    end
  end
  
  return file_list
end

-- Improved fuzzy match with scoring
local function fuzzy_match(text, pattern)
  if pattern == "" then
    return true, 0  -- Empty pattern matches everything with lowest score
  end
  
  text = text:lower()
  pattern = pattern:lower()
  
  local text_len = #text
  local pattern_len = #pattern
  local text_idx, pattern_idx = 1, 1
  local score = 0
  local consecutive = 0
  
  while text_idx <= text_len and pattern_idx <= pattern_len do
    if text:sub(text_idx, text_idx) == pattern:sub(pattern_idx, pattern_idx) then
      -- Match found
      pattern_idx = pattern_idx + 1
      
      -- Bonus for consecutive matches
      consecutive = consecutive + 1
      score = score + consecutive
      
      -- Bonus for matches after separators
      if text_idx > 1 and text:sub(text_idx - 1, text_idx - 1):match("[%./_%- ]") then
        score = score + 3
      end
      
      -- Bonus for matching first character
      if text_idx == 1 then
        score = score + 5
      end
    else
      consecutive = 0
    end
    
    text_idx = text_idx + 1
  end
  
  -- Return true if all pattern chars were matched, along with score
  return pattern_idx > pattern_len, score
end

-- Filter files by pattern and get top N matches
local function filter_files(files, pattern, max_results)
  local matches = {}
  
  for _, file in ipairs(files) do
    local matched, score = fuzzy_match(file, pattern)
    if matched then
      table.insert(matches, {file = file, score = score})
    end
  end
  
  -- Sort by score (higher is better)
  table.sort(matches, function(a, b) return a.score > b.score end)
  
  -- Get top N results
  local results = {}
  for i = 1, math.min(max_results, #matches) do
    table.insert(results, matches[i].file)
  end
  
  return results
end

-- Update the buffer contents
local function update_buffer()
  -- Get filtered files
  local filtered = filter_files(state.files, state.pattern, M.config.max_results)
  
  -- Update the buffer content
  api.nvim_buf_set_option(state.buf, 'modifiable', true)
  
  -- Set the input line with prompt
  local input_line = M.config.prompt .. state.pattern
  
  -- Start with input line
  local lines = {input_line}
  
  -- Add filtered results with indicator for selected line
  for i, file in ipairs(filtered) do
    local prefix = ""
    if state.selected_index == i then
      prefix = "> "
    else
      prefix = "  "
    end
    table.insert(lines, prefix .. file)
  end
  
  -- Fill any remaining lines to maintain window height
  while #lines < M.config.height do
    table.insert(lines, "")
  end
  
  -- Update all lines at once
  api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  
  -- Apply syntax highlighting
  vim.cmd("syntax clear")
  
  -- Highlight the prompt
  vim.cmd("hi FinderPrompt guifg=#569CD6 gui=bold")
  vim.cmd("syntax match FinderPrompt /^" .. vim.fn.escape(M.config.prompt, "[]") .. "/ contained")
  
  -- Highlight the selected line
  if state.selected_index > 0 and state.selected_index <= #filtered then
    vim.cmd("hi FinderSelection guibg=#3a3a3a gui=bold")
    vim.cmd("syntax match FinderSelection /^>.*/ contains=ALL")
  end
  
  api.nvim_buf_set_option(state.buf, 'modifiable', false)
  
  -- Position cursor correctly on the input line
  if state.selected_index == 0 then
    local col = #M.config.prompt + #state.pattern
    api.nvim_win_set_cursor(state.win, {1, col})
  end
end

-- Create a simpler input mode using nvim_buf_set_keymap
local function setup_keymap()
  -- Clear existing keymaps
  api.nvim_buf_set_keymap(state.buf, 'n', '<Esc>', '', { callback = function() M.close() end, noremap = true })
  
  -- Handle character input
  local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-./\\,;:!@#$%^&*()[]{}|"\' '
  for i = 1, #chars do
    local char = chars:sub(i, i)
    api.nvim_buf_set_keymap(state.buf, 'n', char, '', {
      callback = function()
        state.pattern = state.pattern .. char
        update_buffer()
      end,
      noremap = true
    })
  end
  
  -- Handle backspace
  api.nvim_buf_set_keymap(state.buf, 'n', '<BS>', '', {
    callback = function()
      if #state.pattern > 0 then
        state.pattern = string.sub(state.pattern, 1, -2)
        update_buffer()
      end
    end,
    noremap = true
  })
  
  -- Handle navigation
  api.nvim_buf_set_keymap(state.buf, 'n', '<Down>', '', {
    callback = function()
      local filtered = filter_files(state.files, state.pattern, M.config.max_results)
      if #filtered > 0 then
        state.selected_index = math.min(state.selected_index + 1, #filtered)
        update_buffer()
      end
    end,
    noremap = true
  })
  
  api.nvim_buf_set_keymap(state.buf, 'n', '<Up>', '', {
    callback = function()
      if state.selected_index > 0 then
        state.selected_index = state.selected_index - 1
        update_buffer()
      end
    end,
    noremap = true
  })
  
  api.nvim_buf_set_keymap(state.buf, 'n', '<Tab>', '', {
    callback = function()
      local filtered = filter_files(state.files, state.pattern, M.config.max_results)
      if #filtered > 0 then
        state.selected_index = (state.selected_index + 1) % (#filtered + 1)
        update_buffer()
      end
    end,
    noremap = true
  })
  
  api.nvim_buf_set_keymap(state.buf, 'n', '<S-Tab>', '', {
    callback = function()
      local filtered = filter_files(state.files, state.pattern, M.config.max_results)
      if #filtered > 0 then
        state.selected_index = state.selected_index - 1
        if state.selected_index < 0 then
          state.selected_index = #filtered
        end
        update_buffer()
      end
    end,
    noremap = true
  })
  
  -- Handle Enter to select file
  api.nvim_buf_set_keymap(state.buf, 'n', '<CR>', '', {
    callback = function()
      local filtered = filter_files(state.files, state.pattern, M.config.max_results)
      if #filtered > 0 then
        local selected = state.selected_index
        -- If focused on input line, select first result
        if selected == 0 then
          selected = 1
        end
        
        if selected <= #filtered then
          local file_to_open = filtered[selected]
          
          -- Close the finder first
          vim.defer_fn(function()
            M.close()
            
            -- If we're using git files, make sure path is relative to git root
            if state.git_root ~= "" then
              local full_path = state.git_root .. "/" .. file_to_open
              vim.cmd("edit " .. vim.fn.fnameescape(full_path))
            else
              vim.cmd("edit " .. vim.fn.fnameescape(file_to_open))
            end
          end, 10)
        end
      end
    end,
    noremap = true
  })
end

-- Create the bottom split window
local function create_bottom_window()
  -- Create a new empty buffer
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  api.nvim_buf_set_option(buf, 'swapfile', false)
  api.nvim_buf_set_option(buf, 'filetype', 'finder')
  
  -- Open a horizontal split at the bottom with fixed height
  vim.cmd("botright " .. M.config.height .. "split")
  local win = api.nvim_get_current_win()
  api.nvim_win_set_buf(win, buf)
  
  -- Set window options for a minimal interface
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.cursorline = true
  vim.opt_local.signcolumn = "no"
  vim.opt_local.foldcolumn = "0"
  vim.opt_local.wrap = false
  
  -- Set buffer options
  api.nvim_buf_set_option(buf, 'modifiable', true)
  
  -- Initialize with prompt
  local lines = {M.config.prompt}
  
  -- Fill the buffer with empty lines to maintain window height
  while #lines < M.config.height do
    table.insert(lines, "")
  end
  
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Set initial cursor position
  api.nvim_win_set_cursor(win, {1, #M.config.prompt})
  
  return buf, win
end

-- Open the finder
function M.open()
  -- Get git-tracked files
  state.files = get_git_files()
  state.pattern = ""
  state.selected_index = 0
  
  -- Create the window
  state.buf, state.win = create_bottom_window()
  
  -- Set initial buffer state
  update_buffer()
  
  -- Setup keymaps for interaction
  setup_keymap()
  
  -- Enter normal mode (not insert mode) for our custom keys
  vim.cmd("normal! " .. #M.config.prompt .. "l")
end

-- Close the finder
function M.close()
  if state.win and api.nvim_win_is_valid(state.win) then
    api.nvim_win_close(state.win, true)
  end
  
  -- Restore original directory if we changed it
  if state.original_dir ~= "" and state.original_dir ~= vim.fn.getcwd() then
    vim.cmd("cd " .. vim.fn.fnameescape(state.original_dir))
  end
  
  state.win = nil
  state.buf = nil
end

-- Setup function
function M.setup(opts)
  -- Merge user config with defaults
  if opts then
    M.config = vim.tbl_deep_extend("force", M.config, opts)
  end
  
  -- Create user command
  vim.api.nvim_create_user_command("MiniFinder", M.open, {})
  
  -- Example keymapping
  vim.api.nvim_set_keymap('n', '<leader>f', ':MiniFinder<CR>', { noremap = true, silent = true })
end

return M
