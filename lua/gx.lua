local notify = require('gx.notify')
local options = require('gx.options')

local M = {}

-- deliberate incomplete list
local tlds = { 'com', 'net', 'org', 'de', 'uk', 'io', 'gov', 'edu' }

local domain_regex = vim.regex(('[^ /]\\+\\.\\(%s\\)$'):format(vim.fn.join(tlds, '\\|')))
local repo_regex = vim.regex('^[^/]\\+/[^/]\\+$')
local issue_regex = vim.regex('^#[0-9]\\+$')
local commit_regex = vim.regex('^[0-9a-fA-F]\\{5,\\}$')

function M.setup(opts)
  options.set(opts or {})
end

function M.gx()
  local url = M.get_url()

  notify.resolving_done()

  if M.check_if_valid_url(url) then
    M.open(url)
  else
    notify.warning(('No url found for "%s"'):format(url))
  end
end

-- get url under cursor
function M.get_url()
  local word = vim.fn.expand('<cfile>')

  -- complete github repo; require gh command to be installed
  if vim.fn.executable('gh') == 1 then
    if repo_regex:match_str(word) == 0 then
      notify.resolving('repo', word)
      local url, ok = M.gh_api('/repos/' .. word, '.html_url')
      if ok then
        return vim.fn.trim(url)
      end
    end

    if issue_regex:match_str(word) then
      notify.resolving('issue', word)
      local url, ok = M.gh_api('/repos/{owner}/{repo}/issues/' .. word:sub(2), '.html_url')
      if ok then
        return vim.fn.trim(url)
      end
    end

    if commit_regex:match_str(word) then
      notify.resolving('commit', word)
      local url, ok = M.gh_api('/repos/{owner}/{repo}/commits/' .. word, '.html_url')
      if ok then
        return vim.fn.trim(url)
      end
    end
  end

  if domain_regex:match_str(word) == 0 then
    return 'http://' .. word
  end

  return word
end

function M.check_if_valid_url(url)
  return vim.regex('^\\a\\{3,\\}://'):match_str(url) == 0
end

-- open url in default browser
function M.open(url)
  local cmd
  if vim.fn.has('wsl') == 1 then
    cmd = 'wslview'
  elseif vim.fn.has('mac') == 1 then
    cmd = 'open'
  elseif vim.fn.has('unix') == 1 then
    cmd = 'xdg-open'
  else
    vim.notify_once('No open command found!', vim.log.levels.ERROR)
    return
  end

  vim.fn.system(cmd .. ' ' .. vim.fn.shellescape(url))
end

function M.gh_api(endpoint, filter)
  local response, ok = M.exec('gh', { 'api', endpoint, '--jq', filter or '.' })
  if not ok then
    local msg, valid = M.exec('gh', { 'auth', 'status' })
    if not valid then
      notify.error(vim.fn.trim(msg))
    end
  end
  return response, ok
end

--------------------------------------------------------------------------------

function M.exec(cmd, args, timeout)
  args = args or {}
  timeout = timeout or 1000

  local results
  local status = 0
  local done = false

  local chunks = {}
  local handle

  local stdout = vim.loop.new_pipe()
  local errout = vim.loop.new_pipe()

  handle = vim.loop.spawn(
    cmd,
    { args = args, stdio = { nil, stdout, errout } },
    vim.schedule_wrap(function(s)
      stdout:read_stop()
      stdout:close()
      errout:read_stop()
      errout:close()
      handle:close()

      results = table.concat(chunks, '')
      status = s

      done = true
    end)
  )

  local on_read = function(_, chunk)
    if chunk then
      table.insert(chunks, chunk)
    end
  end

  vim.loop.read_start(errout, on_read)
  vim.loop.read_start(stdout, on_read)

  vim.wait(timeout, function()
    return done
  end, 10)

  return results, status == 0
end

return M
