local notify = require('gx.notify')
local gx_os = require('gx.os')

local M = {}

local repo_regex = vim.regex('^[^/]\\+/[^/]\\+$')
local issue_regex = vim.regex('^#[0-9]\\+$')
local commit_regex = vim.regex('^[0-9a-fA-F]\\{5,\\}$')

function M.get_url(word)
  -- complete github repo; require gh command to be installed
  if vim.fn.executable('gh') == 1 then
    if repo_regex:match_str(word) == 0 then
      notify.resolving('repo', word)
      local url, ok = M.gh_api('/repos/' .. word, '.html_url')
      if ok then
        return true, vim.fn.trim(url)
      end
    end

    if issue_regex:match_str(word) then
      notify.resolving('issue', word)
      local url, ok = M.gh_api('/repos/{owner}/{repo}/issues/' .. word:sub(2), '.html_url')
      if ok then
        return true, vim.fn.trim(url)
      end
    end

    if commit_regex:match_str(word) then
      notify.resolving('commit', word)
      local url, ok = M.gh_api('/repos/{owner}/{repo}/commits/' .. word, '.html_url')
      if ok then
        return true, vim.fn.trim(url)
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
