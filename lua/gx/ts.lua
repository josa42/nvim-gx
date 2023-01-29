local M = {}

local exists, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')

M.enabled = exists

local function get_range_text(node)
  if node then
    local r1, c1, r2, c2 = node:range()
    return vim.api.nvim_buf_get_text(0, r1, c1, r2, c2, {})[1]
  end
  return ''
end

local function get_text(node)
  if not node then
    return false
  end

  if node:type() == 'string_fragment' then
    return get_range_text(node)
  end

  if node:type() == 'string' then
    return get_text(node:child(1))
  end

  return ''
end

local function get_parent_by_types(node, types)
  for _, t in ipairs(types) do
    node = node:parent()
    if not node or node:type() ~= t then
      return nil
    end
  end

  return node
end

local function is_import_path(node)
  if not node then
    return false
  end

  if node:type() == 'string' then
    return is_import_path(node:child(1))
  end

  if node:type() == 'string_fragment' then
    -- imports:
    -- > import '<name>'
    -- > import * from '<name>'
    if get_parent_by_types(node, { 'string', 'import_statement' }) then
      return true
    end

    -- import / require call
    -- > import('<name>')
    -- > require('<name>')
    local call_node = get_parent_by_types(node, { 'string', 'arguments', 'call_expression' })
    local call_text = get_range_text(call_node)
    if call_text:sub(0, 7) == 'require' or call_text:sub(0, 6) == 'import' then
      return true
    end
  end

  return false
end

function M.get_import_path_at_cursor()
  local node = ts_utils.get_node_at_cursor()
  if is_import_path(node) then
    return get_text(node)
  end
end

return M
