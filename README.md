# cheat.nvim
This is a minimal battle-used vim plugin to work with cheat sheet from cheat.sh.
Plugin is based on nui (modern UI toolkit) and lua only approach for making a nvim plugin.

Plugin inspired by [cppman.nvim](https://github.com/madskjeldgaard/cppman.nvim)

## Installation

Install using packer. Note that [nui.nvim](https://github.com/MunifTanjim/nui.nvim) is a requirement.

```lua
-- cheat.nvim
use {
  'Partysun/cheat.nvim',
    requires = {
      "MunifTanjim/nui.nvim"
    },
    -- Config part is optional
    config = function()
      local cheat = require"cheat"
      cheat.setup()

      -- Make a keymap to open the word under cursor in Cheat
      vim.keymap.set("n", "<leader>SS", function()
        cheat.open_chtsh_popup(vim.fn.expand("<cword>"))
      end)

      -- Open search box
      vim.keymap.set("n", "<leader>S", function()
        cheat.input()
      end)
    end
}
```

## Usage

Run `:Cheat` without any arguments to get a search prompt 

or with an argument to search for a term: `:Cheat python torch create a tensor scalar`
