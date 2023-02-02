local ts = require('gx.ts')
local gx_os = require('gx.os')

local M = {}

local function get_root_path(source)
  source = source:gsub('["' .. "'" .. ']', ''):gsub('%.', '/')

  local formats = { 'lua/%s.lua', 'lua/%s/init.lua' }
  for _, fmt in ipairs(formats) do
    local pattern = fmt:format(source)
    local paths = vim.api.nvim__get_runtime({ pattern }, false, { is_lua = true })

    if #paths == 1 then
      local dir = paths[1]:sub(1, (-1 * #pattern) - 2)
      local sub = paths[1]:sub(#dir + 2)

      return dir, sub
    end
  end
end

local function gh_repo(cwd, field, query)
  local value, ok = gx_os.exec('gh', { 'repo', 'view', '--json', field, '--jq', query }, { cwd = cwd })
  if ok then
    return vim.fn.trim(value), ok
  end
  return '', false
end

function M.get_url()
  if ts.enabled and vim.opt_local.filetype:get() == 'lua' then
    local source = ts.get_lua_module_at_cursor()
    if not source then
      return false
    end

    local path, sub = get_root_path(source)

    if path:sub(-13) == '/nvim/runtime' then
      return true, ('https://github.com/neovim/neovim/blob/master/runtime/%s'):format(sub)
    end

    local url, url_ok = gh_repo(path, 'url', '.url')
    local branch, branch_ok = gh_repo(path, 'defaultBranchRef', '.defaultBranchRef.name')

    return url_ok and branch_ok, ('%s/blob/%s/%s'):format(url, branch, sub)
  end

  return false
end

return M
