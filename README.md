# nvim GX – [![Test Badge](https://github.com/josa42/nvim-gx/actions/workflows/test.yml/badge.svg)](https://github.com/josa42/nvim-gx/actions/workflows/test.yml)

`nvim-gx` is a simple replacement for the `gx` mapping provided by
[netrw](https://github.com/neovim/neovim/blob/ea2658e1f7a0791f7bf5b1da2417ea0c618121fc/runtime/autoload/netrw.vim#L5255).

<br>

## ✨ Features

Open URLs and more in the default browser:

- URLs (eg. `https://example.org`)
- domains with common TLDs (eg. `example.org`)
- github repos (eg. `josa42/nvim-gx`)[^1]
- github issues (eg. `#13377`)[^1]
- github commit (eg. `b13f2e`)[^1]
- npm packages (eg. `import 'express'`)[^2]
- github links (eg. `[example](https://example.org)`)[^2]

<br>

## ⌨️ Key Mappings

The plugin maps `gx` in normal mode:

```lua
vim.keymap.set('n', 'gx', require('gx').gx)
```

<br>

## 🚛 Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'josa42/nvim-gx'
```

Using packer.nvim

```lua
use {
  'josa42/nvim-gx'
}
```

<br>

## 📦 Dependencies

To resolve _repos_, _issues_ or _commits_ [`gh`](https://cli.github.com/) needs
to be installed and authenticated.

```sh
# verify authentication:
gh auth status

# authenticate with GitHub:
gh auth
```

<br>

To resolve npm packages and markdown links
[`nvim-treesitter`]((https://github.com/nvim-treesitter/nvim-treesitter)) needs
to be installed.

```lua
require('nvim-treesitter.configs').setup({
  ensure_installed = { 'javascript', 'markdown', 'markdown_inline' },
})
```

<br>

## 🔧 Setup

Setup function to set options.

Usage:

```lua
require('gx').setup({
  show_notifications = true,
  show_progress = false,
})
```

**Valid keys for `{opts}`**

- `show_notifications`  
 Determines if notifications are shown.

- `show_progress`:  
  Determines if progress notifications are shown.

<br>

## License

[MIT © Josa Gesell](LICENSE)

<br>

[^1]: Requires [`gh`](https://cli.github.com/) to be installed and authenticated, run `gh auth` to authenticate.
[^2]: Requires [`nvim-treesitter/nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter)
