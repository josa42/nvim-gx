vim.keymap.set('n', 'gx', function()
  local gx = require('gx')
  gx.browse_x(gx.gx(), gx.check_if_remote(gx.gx()))
end)
