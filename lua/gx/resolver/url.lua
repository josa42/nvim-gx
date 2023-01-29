local M = {}

-- deliberate incomplete list
local tlds = { 'com', 'net', 'org', 'de', 'uk', 'io', 'gov', 'edu' }

local domain_regex = vim.regex(('[^ /]\\+\\.\\(%s\\)$'):format(vim.fn.join(tlds, '\\|')))

function M.get_url(word)
  if domain_regex:match_str(word) == 0 then
    return true, 'http://' .. word
  end

  return false
end

return M
