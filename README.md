# nvim GX

`nvim-gx` is a simple replacement for the `gx` mapping provided by
[netrw](https://github.com/neovim/neovim/blob/ea2658e1f7a0791f7bf5b1da2417ea0c618121fc/runtime/autoload/netrw.vim#L5255).

## ✨ Features

Open URLs and more in the default browser:

- URLs (eg. `https://example.org`)
- domains with common TLDs (eg. `example.org`)
- github repos (eg. `josa42/nvim-gx`)[^1]
- github issues (eg. `#13377`)[^1]

## ⌨️ Key Mappings

The plugin maps `gx` in normal mode:

```lua
vim.keymap.set('n', 'gx', require('gx').gx)
```

## TODO

- handle git commit hashes

## License

[MIT © Josa Gesell](LICENSE)

[^1]: Requires [`gh`](https://cli.github.com/) to be installed.
