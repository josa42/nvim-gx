local M = {}

-- https://github.com/neovim/neovim/blob/master/runtime/autoload/netrw.vim#L5255

-- ---------------------------------------------------------------------
-- netrw#BrowseX:  (implements "x" and "gx") executes a special "viewer" script or program for the
--              given filename; typically this means given their extension.
--              0=local, 1=remote
function M.browse_x(fname, remote)
  if remote then
    M.open(fname)
  end

  -- local r = 0
  -- if remote then
  --   r = 1
  -- end
  --
  -- return vim.fn['netrw#BrowseX'](fname, r)
end

-- ---------------------------------------------------------------------
-- netrw#CheckIfRemote: returns 1 if current file looks like an url, 0 else
function M.check_if_remote(...)
  local a = { ... }

  local curfile

  if #a > 0 then
    curfile = a[1]
  else
    curfile = vim.fn.expand('%')
  end

  -- Ignore terminal buffers
  if vim.fn.buftype == 'terminal' then
    return 0
  end

  -- print('> ' .. curfile)
  -- D(vim.fn['netrw#CheckIfRemote'](...))

  return vim.regex('^\\a\\{3,\\}://'):match_str(curfile) == 0
end

-- ---------------------------------------------------------------------
-- netrw#GX: gets word under cursor for gx support
--           See also: netrw#BrowseXVis
--                     netrw#BrowseX
function M.gx()
  local word = vim.fn.expand('<cfile>')

  if vim.regex('^[^/]\\+/[^/]\\+$'):match_str(word) == 0 then
    return 'https://github.com/' .. word
  end

  return word
end

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
