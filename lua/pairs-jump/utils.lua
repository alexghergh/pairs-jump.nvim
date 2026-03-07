local M = {}

local function feed_mapping_keys(keys, map)
    if keys == nil then
        return
    end

    if type(keys) ~= 'string' then
        keys = tostring(keys)
    end

    local should_replace_keycodes = map.expr ~= 1 or map.replace_keycodes == 1
    if should_replace_keycodes then
        keys = vim.api.nvim_replace_termcodes(keys, true, true, true)
    end

    local feed_mode = map.noremap == 1 and 'in' or 'im'
    vim.api.nvim_feedkeys(keys, feed_mode, false)
end

local function get_mapping_result(map)
    if map.callback then
        return map.callback()
    end

    if map.expr == 1 then
        return vim.fn.eval(map.rhs)
    end

    return map.rhs
end

-- get a default callback function for a specific mapping
M.get_fallback_mapping = function(mode, lhs)
    local map = vim.fn.maparg(lhs, mode, false, true)
    if vim.tbl_isempty(map) then
        return nil
    end

    -- normalize the saved mapping so callers can invoke it like a plain
    -- function
    return function()
        if map.expr == 1 then
            feed_mapping_keys(get_mapping_result(map), map)
            return
        end

        if map.callback then
            map.callback()
            return
        end

        feed_mapping_keys(map.rhs, map)
    end
end

M.jump_left = function(delimiters, viewport_only, respect_scrolloff, jump_after)
    -- start from current position
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- scrolloff at the exact start of the buffer doesn't move the window, so we
    -- should ignore it there
    local scrloff_reg = 0
    if viewport_only and respect_scrolloff then
        if vim.fn.line('w0') ~= 1 then
            scrloff_reg = vim.o.scrolloff
        end
    end

    -- max lines to search (whole buffer or just the current viewport)
    local line_count = 1
    if viewport_only then
        line_count = vim.fn.line('w0')
    end

    for line_idx = row, line_count + scrloff_reg, -1 do
        -- get current line
        local line =
            vim.api.nvim_buf_get_lines(0, line_idx - 1, line_idx, false)[1]

        local delim_col = 0
        local delim_found = false

        -- iterate over all the delimiters and get the closest one to the cursor
        for _, delim in pairs(delimiters) do
            local cur_index = line:reverse():find(
                delim,
                line_idx == row and #line - col + (jump_after and 1 or 2) or 0,
                true
            )
            if cur_index then
                cur_index = #line - cur_index + 1
            end
            if cur_index and (cur_index > delim_col) then
                delim_col = cur_index
                delim_found = true
            end
        end

        -- finally, if we found a match, jump and return success
        if delim_found then
            vim.api.nvim_win_set_cursor(
                0,
                { line_idx, delim_col - (jump_after and 1 or 0) }
            )
            return true
        end
    end
    return false
end

M.jump_right = function(
    delimiters,
    viewport_only,
    respect_scrolloff,
    jump_after
)
    -- start from current position
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- scrolloff at the exact end of the buffer doesn't move the window, so we
    -- should ignore it there
    local scrloff_reg = 0
    if viewport_only and respect_scrolloff then
        if vim.api.nvim_buf_line_count(0) ~= vim.fn.line('w$') then
            scrloff_reg = vim.o.scrolloff
        end
    end

    -- max lines to search (whole buffer or just the current viewport)
    local line_count = vim.api.nvim_buf_line_count(0)
    if viewport_only then
        line_count = vim.fn.line('w$')
    end

    for line_idx = row, line_count - scrloff_reg do
        -- get current line
        local line =
            vim.api.nvim_buf_get_lines(0, line_idx - 1, line_idx, false)[1]

        local delim_col = #line + 1
        local delim_found = false

        -- iterate over all the delimiters and get the closest one to the cursor
        for _, delim in pairs(delimiters) do
            local cur_index = line:find(
                delim,
                line_idx == row and col + (jump_after and 1 or 2) or 0,
                true
            )
            if cur_index and (cur_index < delim_col) then
                delim_col = cur_index
                delim_found = true
            end
        end

        -- finally, if we found a match, jump and return success
        if delim_found then
            vim.api.nvim_win_set_cursor(
                0,
                { line_idx, delim_col - (jump_after and 0 or 1) }
            )
            return true
        end
    end
    return false
end

return M
