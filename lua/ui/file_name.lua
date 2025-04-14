function ShortPath()
    local path = vim.fn.expand('%:p')
    local parts = {}
    for part in string.gmatch(path, "[^/]+") do
        table.insert(parts, part)
    end
    local n = #parts
    return table.concat({ parts[n-2] or '', parts[n-1] or '', parts[n] or '' }, '/')
end

vim.opt.statusline = '%f %m %r %= ' .. '%{v:lua.ShortPath()}'

