# commented.nvim

A commenting plugin written in Lua that actually works.

This plugin uses `commentstring` and custom comment definition for accurately comment and uncomment code.

![normal mode demo](./gif/normal-mode-demo.gif)

## Features

- Provide sensible comment symbols default for **as much language as possible** (Always a WIP)

- Handle multi-line block comment, both commenting and uncommenting

- Commenting lines in normal mode and visual line mode

- Support **counts** for commenting in normal mode (e.g. `2<leader>c2j`, `3<leader>cc`)

- Toggleable commenting command

- Handle uncommenting **multiple comment patterns(inline and block comment)** correctly

- Handle comments with various spacing correctly

- Comment ex-mode command that handles range included

- Provide the correct `commentstring` for filetype not handled by neovim initially

## Demo

### Commenting in normal mode with count

![normal mode demo](./gif/normal-mode-demo.gif)

### Commenting in virtual line mode

![visual-mode-demo](./gif/visual-mode-demo.gif)

### Uncommenting both inline and block comment

![various comment patterns](./gif/various-comment-format-demo.gif)

## Why another comment plugin?

I need a comment plugin that works in normal mode and virtual mode and accepts count. Neither does [kommentary](https://github.com/b3nj5m1n/kommentary) and [nvim-comment](https://github.com/terrortylor/nvim-comment) provide counts, therefore I decided to write one for myself.

## Installation

### `Paq.nvim`

```lua
paq{'winston0410/commented.nvim'}
```

### `vim-plug`

```lua
Plug 'winston0410/commented.nvim'
```

### `packer.nvim`

Do not set this plugin as optional, as sensible default has been made with `ftplugin`

```lua
use{'winston0410/commented.nvim'}
```

## Configuration

This is the default configuration.

```lua
local opts = {
	comment_padding = " ", -- padding between starting and ending comment symbols
	keybindings = {n = "<leader>c", v = "<leader>c", nl = "<leader>cc"}, -- what key to toggle comment, nl is for mapping <leader>c$, just like dd for d
	prefer_block_comment = false, -- Set it to true to automatically use block comment when multiple lines are selected
	set_keybindings = true, -- whether or not keybinding is set on setup
	ex_mode_cmd = "Comment" -- command for commenting in ex-mode, set it null to not set the command initially.
}
```

You can define your own mapping with `require('commented').toggle_comment(mode)`

If you are happy with it, just call `setup()` to make it start working.

```lua
require('commented').setup()
```

## Doesn't work for the language I use

If this plugin doesn't work for the language you use, you can [contribute and add those symbols here](https://github.com/winston0410/commented.nvim/blob/94246498eb89948271bbeedf0e64d78b28510720/lua/commented/init.lua#L7-L40) for that language. The key for the pattern doesn't matter.

## Inspiration

[kommentary](https://github.com/b3nj5m1n/kommentary)

[nvim-comment](https://github.com/terrortylor/nvim-comment)
