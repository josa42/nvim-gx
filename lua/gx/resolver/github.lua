local notify = require('gx.notify')
local gx_os = require('gx.os')

local M = {}

local types = {
  {
    name = 'repo',
    pattern = vim.regex('^[^/]\\+/[^/]\\+$'),
    endpoint = function(word)
      return ('/repos/%s'):format(word)
    end,
  },
  {
    name = 'issue',
    pattern = vim.regex('^#[0-9]\\+$'),
    endpoint = function(word)
      return ('/repos/{owner}/{repo}/issues/%s'):format(word:sub(2))
    end,
  },
  {
    name = 'commit',
    pattern = vim.regex('^[0-9a-fA-F]\\{5,\\}$'),
    endpoint = function(word)
      return ('/repos/{owner}/{repo}/commits/%s'):format(word)
    end,
  },
}

function M.get_url(word)
  -- complete github repo; require gh command to be installed
  if vim.fn.executable('gh') == 1 then
    for _, t in ipairs(types) do
      if t.pattern:match_str(word) == 0 then
        notify.resolving(t.name, word)

        local url, ok = M.gh_api(t.endpoint(word), '.html_url')
        if ok then
          return true, vim.fn.trim(url)
        end
      end
    end
  end

  return false
end

function M.gh_api(endpoint, filter)
  local response, ok = gx_os.exec('gh', { 'api', endpoint, '--jq', filter or '.' })
  if not ok then
    local msg, valid = gx_os.exec('gh', { 'auth', 'status' })
    if not valid then
      notify.error(vim.fn.trim(msg))
    end
  end
  return response, ok
end

return M
