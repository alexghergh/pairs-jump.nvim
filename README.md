## pairs-jump.nvim

Automatically jump to the closest quote / bracket / pair of some sort in insert
mode.

### Inspiration

I found the inspiration to write this plugin when using
[nvim-autopairs](https://github.com/windwp/nvim-autopairs). I found that,
despite the plugin automatically inserting pairs of brackets, it would sometimes
fail to capture the intent of "I finished with all the pairs, move me after the
constructs". Normally, you could simply press the closing bracket, which would
achieve this effect, however this sort of defeats the purpose of the plugin. I
still find it helpful (mostly for multi-line stuff, + one-shotting things where
I don't have to write any text _after_ the pairs of quotes / brackets). It also
fails, for example, in the following case:

```lua
{
    sometext,|
}
```

Being in this position, I want to type `}` and move to:

```lua
{
    sometext,
}|
```

However the result would (disastrously) be:

```lua
{
    sometext,|}
}
```

(This mostly happens because of lack of multi-line support in the plugin.)

With the current plugin, however, you could simply type `<A-l>` (i.e. *Alt + l
key*) **in insert mode**, and get the desired behaviour, which is also
consistent across multiple quotes / brackets / symbols types.

Of course, this plugin is independent from `autopairs` and works well even
without it installed alongside.

### Installation

Use your favorite plugin manager. For example, using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    'alexghergh/pairs-jump.nvim',
    -- use opts = {} for passing setup options
}
```

### Configuration

Further configuration is possible. Below are all the options (default values):

```lua
{
    'alexghergh/pairs-jump.nvim',
    opts = {
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
    },
}
```
