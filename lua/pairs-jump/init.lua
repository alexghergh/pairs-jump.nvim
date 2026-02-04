local utils = require('pairs-jump.utils')

local defaults = {
    delimiters = {
        -- left and right determine the direction in which the search
        -- happens; for example, upon pressing the left jump keymap, the
        -- delimiters defined by left here will be searched
        left = { '(', '[', '{', '<', "'", '"', '`' },
        right = { ')', ']', '}', '>', "'", '"', '`' },
    },

    keymaps = {
        search_left = '<A-h>', -- mapped in insert mode
        search_right = '<A-l>', -- mapped in insert mode
    },

    -- whether to position the cursor after the delimiter (i.e. away from
    -- the cursor, on the other side of the delimiter), or before the
    -- delimiter (i.e. closer to the cursor, between the delimiter and the
    -- cursor)
    jump_after_delimiter = true,

    -- whether to use the default mapping on failure to find the pair to
    -- jump to (you could e.g. bind the same keymaps above to moving left /
    -- right one position; this will fallback to that in the described case)
    fallback = true,

    -- whether to search only the current (window) viewport, or the whole
    -- buffer; setting this may be more comfortable in situations where you
    -- don't want to be surprised by the cursor jumping off the screen;
    -- instead, keeps the cursor on the visible viewport
    current_viewport_only = true,

    -- if `current_viewport_only` is set to `true`, also respects scrolloff,
    -- in order to not move the user viewport at all; otherwise, if jumping
    -- into a scrolloff region, the window will slightly adjust up/down
    respect_scrolloff = true,
}

local M = {}

M.setup = function(opts)
    -- merge user configs
    M.config = vim.tbl_deep_extend('force', defaults, opts or {})

    -- get fallbacks
    local left_default_callback = M.config.fallback
            and utils.get_fallback_mapping('i', M.config.keymaps.search_left)
        or function() end
    local right_default_callback = M.config.fallback
            and utils.get_fallback_mapping('i', M.config.keymaps.search_right)
        or function() end

    -- left search + jump
    vim.keymap.set('i', M.config.keymaps.search_left, function()
        if
            not utils.jump_left(
                M.config.delimiters.left,
                M.config.current_viewport_only,
                M.config.respect_scrolloff,
                M.config.jump_after_delimiter
            )
        then -- didn't find pair
            left_default_callback()
        end
    end, { desc = 'Pairs jump left' })

    -- right search + jump
    vim.keymap.set('i', M.config.keymaps.search_right, function()
        if
            not utils.jump_right(
                M.config.delimiters.right,
                M.config.current_viewport_only,
                M.config.respect_scrolloff,
                M.config.jump_after_delimiter
            )
        then -- didn't find pair
            right_default_callback()
        end
    end, { desc = 'Pairs jump right' })
end

return M
