# commented.nvim

A commenting plugin written in Lua that actually works.

## Features

- commenting lines in normal mode and visual line mode

- commenting words in visual mode (**WIP**)

- support **counts** for commenting in normal mode

- toggleable commenting command

## Why another comment plugin?

I need to comment plugin that works in normal that accepts counts and in virtual line mode. Neither does [kommentary](https://github.com/b3nj5m1n/kommentary) and [nvim-comment](https://github.com/terrortylor/nvim-comment) provide counts, therefore I decided to write one for myself.

## Installation

### `Paq.nvim`

```lua
paq{'winston0410/commented.nvim'}
```

### `vim-plug`

```lua
Plug 'winston0410/commented.nvim'
```

## Configuration

This is the default configuration.

```lua
local opts = {
	comment_padding = " ", -- padding between starting and ending comment symbols
	keybindings = {n = "<leader>c", v = "<leader>c"}, -- what key to toggle comment
	set_keybindings = true -- whether or not keybinding is set on setup
}
```

If you are happy with it, just call `setup()` to make it start working.

```lua
require('commented').setup()
```

## Inspiration

[kommentary](https://github.com/b3nj5m1n/kommentary)

[nvim-comment](https://github.com/terrortylor/nvim-comment)
