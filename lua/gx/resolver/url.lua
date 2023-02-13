local tlds = require('gx.tlds')

local M = {}

local domain_regex = vim.regex(('[^ /]\\+\\.\\(%s\\)$'):format(vim.fn.join(tlds, '\\|')))

function M.get_url(word)
  if domain_regex:match_str(word) == 0 then
    return true, 'http://' .. word
  end

  return false
end

return M
