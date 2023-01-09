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

  if vim.regex('^[^/]\\+/[^/]\\+$'):match_str(word) == 0 then
    return 'https://github.com/' .. word
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

return M
