local ts = require('gx.ts')

local M = {}

function M.get_url()
  if ts.enabled and vim.opt_local.filetype:get() == 'markdown' then
    local link = ts.get_md_link_at_cursor()

    if link and link:match('^https?://') then
      return true, link
    end

    if link and link:match('^[^/:]+%.[a-z]+') then
      return true, 'https://' .. link
    end
  end

  return false
end

return M
