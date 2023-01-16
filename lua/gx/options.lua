M = {}

M.values = {
  show_progress = false,
  show_notifications = true,
}

M.set = function(opts)
  opts.set = M.set
  M.values = vim.tbl_extend('force', M.values, opts)
end

return setmetatable(M, {
  __index = function(t, key)
    return t.values[key]
  end,
})
