local notify = require('gx.notify')
local options = require('gx.options')
local gx_os = require('gx.os')

local M = {}

-- resolvers are expected to export get_url(word, string): boolean, string
local resolvers = {
  require('gx.resolver.url'),
  require('gx.resolver.npm'),
  require('gx.resolver.markdown'),
  require('gx.resolver.github'),
  require('gx.resolver.lua'),
}

function M.setup(opts)
  options.set(opts or {})
end

function M.gx()
  local url = M.get_url()

  notify.resolving_done()

  if M.check_if_valid_url(url) then
    gx_os.open(url)
  else
    notify.warning(('No url found for "%s"'):format(url))
  end
end

-- get url under cursor
function M.get_url()
  local word = vim.fn.expand('<cfile>')

  for _, resolver in ipairs(resolvers) do
    local found, url = resolver.get_url(word)
    if found then
      return url
    end
  end

  return word
end

function M.check_if_valid_url(url)
  return vim.regex('^\\a\\{3,\\}://'):match_str(url) == 0
end

return M
