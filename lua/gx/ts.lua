local M = {}

local exists, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')

M.enabled = exists

local function get_text(node)
  if node then
    local r1, c1, r2, c2 = node:range()
    return vim.api.nvim_buf_get_text(0, r1, c1, r2, c2, {})[1]
  end
  return ''
end

local function get_string_text(node)
  if not node then
    return false
  end

  if node:type() == 'string_fragment' then
    return get_text(node)
  end

  if node:type() == 'string' then
    return get_string_text(node:child(1))
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

local function get_child_by_type(node, type)
  for c in node:iter_children() do
    if c and c:type() == type then
      return c
    end
  end
end

local function dump_children(node)
  local i = 1
  for c in node:iter_children() do
    print(i, c:type(), get_text(c))
    i = i + 1
  end
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
    local call_text = get_text(call_node)
    if call_text:sub(0, 7) == 'require' or call_text:sub(0, 6) == 'import' then
      return true
    end
  end

  return false
end

function M.get_import_path_at_cursor()
  local node = ts_utils.get_node_at_cursor()
  if is_import_path(node) then
    return get_string_text(node)
  end
end

function M.get_md_link_at_cursor()
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return
  end

  if node:type() == 'link_destination' then
    return get_text(node)
  end

  if node:type() == 'link_text' then
    node = node:parent()
  end

  -- [lext](destination)
  if node:type() == 'inline_link' then
    local link = get_child_by_type(node, 'link_destination')
    if link then
      return get_text(link)
    end
  end

  -- TODO
  -- [lext][label]

  -- if node:type() == 'full_reference_link' then
  --   local label = get_child_by_type(node, 'link_label')
  --   if label then
  --     print('label', get_text(label))
  --     -- local root = ts_utils.get_root_for_node(node)
  --     -- return get_text(link)
  --   end
  -- end
end

function M.get_lua_module_at_cursor()
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return
  end

  if node:type() == 'link_destination' then
    return get_text(node)
  end

  local fn_call = get_parent_by_types(node, { 'arguments', 'function_call' })
  local fn_name = get_child_by_type(fn_call, 'identifier')

  if get_text(fn_name) == 'require' then
    return get_text(node)
  end
end

return M
