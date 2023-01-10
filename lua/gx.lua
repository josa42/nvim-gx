local M = {}

function M.gx()
  local url = M.get_url()
  if M.check_if_valid_url(url) then
    M.open(url)
  end
end

-- get url under cursor
function M.get_url()
  local word = vim.fn.expand('<cfile>')

  -- complete github repo; require gh command to be installed
  if vim.fn.executable('gh') == 1 and vim.regex('^[^/]\\+/[^/]\\+$'):match_str(word) == 0 then
    local url, ok = M.exec('gh', { 'api', '/repos/' .. word, '--jq', '.html_url' })
    if ok then
      return vim.fn.trim(url)
    end
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

  handle = vim.loop.spawn(
    cmd,
    { args = args, stdio = { nil, stdout, nil } },
    vim.schedule_wrap(function()
      stdout:read_stop()
      stdout:close()
      handle:close()

      results = table.concat(chunks, '')
      status = 0

      done = true
    end)
  )

  local on_read = function(_, chunk)
    if chunk then
      table.insert(chunks, chunk)
    end
  end

  vim.loop.read_start(stdout, on_read)

  vim.wait(timeout, function()
    return done
  end, 10)

  return results, status == 0
end

return M
