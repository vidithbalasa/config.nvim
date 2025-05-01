local M = {}

-- Store marked positions (up to 3)
M.marks = {}

-- Define signs for marked spots
local function setup_signs()
    vim.fn.sign_define("MarkSpot1", { text = "①", texthl = "MarkSpot1" })
    vim.fn.sign_define("MarkSpot2", { text = "②", texthl = "MarkSpot2" })
    vim.fn.sign_define("MarkSpot3", { text = "③", texthl = "MarkSpot3" })

    -- Define highlight groups for the signs
    vim.cmd([[
        highlight default MarkSpot1 guifg=#FF5555 ctermfg=203
        highlight default MarkSpot2 guifg=#50FA7B ctermfg=84
        highlight default MarkSpot3 guifg=#8BE9FD ctermfg=117
    ]])
end

-- Mark a spot
function M.mark_spot(index)
    if index < 1 or index > 3 then
        vim.notify("Invalid mark index. Must be between 1 and 3.", vim.log.levels.ERROR)
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Remove previous mark if it exists in this buffer
    if M.marks[index] and M.marks[index].bufnr == bufnr then
        vim.fn.sign_unplace("MarkSpots", { id = index, buffer = bufnr })
    end

    -- Store the new mark
    M.marks[index] = {
        bufnr = bufnr,
        line = line,
        col = col,
        filename = vim.api.nvim_buf_get_name(bufnr)
    }

    -- Place the sign (priority 10 ensures it doesn't interfere with LSP diagnostics)
    vim.fn.sign_place(
        index,
        "MarkSpots",
        "MarkSpot" .. index,
        bufnr,
        { lnum = line, priority = 10 }
    )

    vim.notify("Spot " .. index .. " marked at line " .. line, vim.log.levels.INFO)
end

-- Jump to a marked spot
function M.jump_to_spot(index)
    if not M.marks[index] then
        vim.notify("Spot " .. index .. " not marked yet", vim.log.levels.WARN)
        return
    end

    local mark = M.marks[index]

    -- If the marked buffer doesn't exist anymore, notify and return
    if not vim.api.nvim_buf_is_valid(mark.bufnr) then
        vim.notify("The buffer for spot " .. index .. " is no longer available", vim.log.levels.WARN)
        M.marks[index] = nil
        return
    end

    -- If the mark is in a different buffer, switch to it
    if mark.bufnr ~= vim.api.nvim_get_current_buf() then
        vim.cmd("buffer " .. mark.bufnr)
    end

    -- Jump to the position
    vim.api.nvim_win_set_cursor(0, { mark.line, mark.col })

    -- Center the view
    vim.cmd("normal! zz")
end

-- Set up keymappings
function M.setup_keymaps()
    -- Maps for marking spots
    vim.keymap.set('n', '<leader>ma', function() M.mark_spot(1) end, { desc = "Mark spot 1" })
    vim.keymap.set('n', '<leader>ms', function() M.mark_spot(2) end, { desc = "Mark spot 2" })
    vim.keymap.set('n', '<leader>md', function() M.mark_spot(3) end, { desc = "Mark spot 3" })

    -- Maps for jumping to spots
    vim.keymap.set('n', '<leader>a', function() M.jump_to_spot(1) end, { desc = "Jump to spot 1" })
    vim.keymap.set('n', '<leader>s', function() M.jump_to_spot(2) end, { desc = "Jump to spot 2" })
    vim.keymap.set('n', '<leader>d', function() M.jump_to_spot(3) end, { desc = "Jump to spot 3" })
end

-- Initialize the plugin
function M.setup()
    setup_signs()
    M.setup_keymaps()

    -- Create an autocommand group for our plugin
    local augroup = vim.api.nvim_create_augroup("MarkSpots", { clear = true })

    -- Create an autocommand to restore marks when a buffer is loaded
    vim.api.nvim_create_autocmd("BufEnter", {
        group = augroup,
        callback = function(args)
            local bufnr = args.buf

            -- Check each mark and place sign if it's for this buffer
            for i = 1, 3 do
                if M.marks[i] and M.marks[i].bufnr == bufnr then
                    vim.fn.sign_place(
                        i,
                        "MarkSpots",
                        "MarkSpot" .. i,
                        bufnr,
                        { lnum = M.marks[i].line, priority = 10 }
                    )
                end
            end
        end
    })
end

return M
