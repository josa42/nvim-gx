local ts = require('gx.ts')

local npm_filetypes =
  { 'javascript', 'javascript.jsx', 'javascriptreact', 'typescript', 'typescript.jsx', 'typescriptreact' }
local npm_pkg_regex = vim.regex('^\\(@[^/]\\+/[^/]\\+\\|[^@.][^/]*\\)')

local M = {}

local function npm_url(name)
  if name:match('/') and name:match('^@') ~= nil then
    word = ('@%s'):format(word)
  end

  return ('https://www.npmjs.com/package/%s'):format(name)
end

function M.get_url(word)
  if vim.fn.expand('%:t') == 'package.json' then
    local start = npm_pkg_regex:match_str(word)
    if start == 0 then
      return true, npm_url(word)
    end
  end

  if ts.enabled and vim.tbl_contains(npm_filetypes, vim.opt_local.filetype:get()) then
    local path = ts.get_import_path_at_cursor()
    if path then
      local start, len = npm_pkg_regex:match_str(path)
      if start == 0 then
        return true, npm_url(path:sub(start, len))
      end
    end
  end

  return false
end

return M
