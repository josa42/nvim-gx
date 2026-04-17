install_plug('https://github.com/nvim-treesitter/nvim-treesitter.git')

local ok, ts_config = pcall(require, 'nvim-treesitter.configs')
if ok then
  ts_config.setup({
    sync_install = true,
    ensure_installed = { 'javascript', 'typescript', 'markdown', 'markdown_inline' },
  })
end
print('\n')
