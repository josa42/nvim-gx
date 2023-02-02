install_plug('https://github.com/nvim-treesitter/nvim-treesitter.git')

require('nvim-treesitter.configs').setup({
  sync_install = true,
  ensure_installed = { 'javascript', 'markdown', 'markdown_inline' },
})
print('\n')
