local options = require('gx.options')

local M = {}

local notify_available, notify = pcall(require, 'notify')

local spinner_frames = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' }

function M.progress(msg)
  if not notify_available or not options.show_progress or not options.show_notifications then
    return { done = function() end }
  end

  local notification = nil
  local i = 1
  local done = false

  local function update()
    i = i + 1

    notification = notify(('%s %s'):format(spinner_frames[(i % #spinner_frames) + 1], msg), nil, {
      replace = notification,
      hide_from_history = true,
      timeout = done and 1 or nil,
    })

    if not done then
      vim.defer_fn(function()
        update()
      end, 100)
    end
  end

  update()

  return {
    done = function()
      vim.defer_fn(function()
        done = true
      end, 500)
    end,
  }
end

function M.warning(msg)
  if options.show_notifications then
    vim.notify(msg, vim.log.levels.WARN)
  end
end

function M.error(msg)
  if options.show_notifications then
    vim.notify(msg, vim.log.levels.ERROR)
  end
end

local resolving_progress = nil

function M.resolving_done()
  if resolving_progress ~= nil then
    resolving_progress.done()
  end
end

function M.resolving(type, word)
  M.resolving_done()
  resolving_progress = M.progress(('Resolve "%s" %s'):format(word, type))
end

return M
