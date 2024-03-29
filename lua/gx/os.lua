local M = {}

-- open url in default browser
function M.open(url)
  if vim.ui.open ~= nil then
    return vim.ui.open(url)
  end

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

function M.exec(cmd, args, opts)
  opts = opts or {}
  args = args or {}

  local timeout = opts.timeout or 2000

  local results
  local status = 0
  local done = false

  local chunks = {}
  local handle

  local stdout = vim.loop.new_pipe()
  local errout = vim.loop.new_pipe()

  handle = vim.loop.spawn(
    cmd,
    { args = args, stdio = { nil, stdout, errout }, cwd = opts.cwd },
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
