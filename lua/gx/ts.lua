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

local function find_up_by_type(node, type)
  while node ~= nil do
    if node and node:type() == type then
      return node
    end
    node = node:parent()
  end

  return nil
end

local function get_child_by_type(node, type)
  for c in node:iter_children() do
    if c and c:type() == type then
      return c
    end
  end
end

local function get_child_by_types(node, types)
  for _, t in ipairs(types) do
    node = get_child_by_type(node, t)
    if not node then
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
    local call_text = get_text(call_node)
    if call_text:sub(0, 7) == 'require' or call_text:sub(0, 6) == 'import' then
      return true
    end
  end

  return false
end

function M.get_import_path_at_cursor()
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return nil
  end

  -- import m from 'mod'
  local import_node = find_up_by_type(node, 'import_statement')
  if import_node ~= nil then
    node = get_child_by_types(import_node, { 'string' })
  end

  -- import 'mod'
  local import_call_node = find_up_by_type(node, 'import')
  if import_call_node ~= nil and get_text(import_call_node) == 'import' then
    node = get_child_by_types(import_call_node:parent(), { 'arguments', 'string' })
  end

  -- const m = import('mod')
  -- const m = await import('mod')
  local declaration_node = find_up_by_type(node, 'lexical_declaration')
  if declaration_node ~= nil then
    -- const m = require('mod')
    node = get_child_by_types(declaration_node, { 'variable_declarator', 'call_expression', 'arguments', 'string' })
      or get_child_by_types(
        declaration_node,
        { 'variable_declarator', 'await_expression', 'call_expression', 'arguments', 'string' }
      )
  end

  -- import('mod')
  -- await import('mod')
  -- require('mod')
  local expression_statement = find_up_by_type(node, 'expression_statement')
  if expression_statement ~= nil then
    local call_expression = get_child_by_types(expression_statement, { 'call_expression' })
      or get_child_by_types(expression_statement, { 'await_expression', 'call_expression' })

    local identifier = get_child_by_types(call_expression, { 'identifier' })
    if identifier ~= nil and get_text(identifier) == 'require' then
      node = get_child_by_types(call_expression, { 'arguments', 'string' })
    end

    local import = get_child_by_types(call_expression, { 'import' })
    if import ~= nil and get_text(import) == 'import' then
      node = get_child_by_types(call_expression, { 'arguments', 'string' })
    end
  end

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

  if vim.tbl_contains({ 'link_text', 'link_label' }, node:type()) then
    node = node:parent()
  end

  -- [text](destination)
  if node:type() == 'inline_link' then
    local link = get_child_by_type(node, 'link_destination')
    if link then
      return get_text(link)
    end
  end

  -- [text][label]
  if node:type() == 'full_reference_link' then
    local label_node = get_child_by_type(node, 'link_label')
    if label_node then
      local label = get_text(label_node)

      for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 1, -1, true)) do
        local l_label, url = line:match('(%[.*%]) *: *(.*)$')
        if l_label == label then
          return vim.fn.trim(url)
        end
      end
    end
  end
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
