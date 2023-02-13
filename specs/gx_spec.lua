local spy = require('luassert.spy')

local urls = {
  'https://example.org',
  'https://example.org/index.html',
  'https://example.org/path/index.html',
  'https://example.org/path/',
  'http://example.org',
  'ftp://example.org',
}

local commit = 'b13f2e931e6f1dd98ed1e002eb3a967e13bb8ee4'

local domains = {
  'example.com',
  'example.net',
  'example.org',
  'example.de',
}

local not_urls = {
  '',
  'foo',
  'foo/bar.com',
  'example.notatld',
  '#999999999',
  '1',
  'b13f',
  '00000',
}

local cases = {
  {
    filetypes = { '' },
    tests = vim.tbl_map(function(url)
      return {
        label = ('url "%s"'):format(url),
        content = url,
        cursors = '^',
        expect = url,
      }
    end, urls),
  },
  {
    filetypes = { '' },
    tests = {
      {
        label = 'repo "neovim/neovim"',
        content = 'neovim/neovim',
        cursors = '^',
        expect = 'https://github.com/neovim/neovim',
      },
    },
  },
  {
    filetypes = { '' },
    tests = {
      {
        label = 'issue "#1"',
        content = '#1',
        cursors = '^',
        expect = 'https://github.com/josa42/nvim-gx/issues/1',
      },
    },
  },
  {
    filetypes = { '' },
    tests = {
      {
        label = 'commit',
        content = commit,
        cursors = '^',
        expect = ('https://github.com/josa42/nvim-gx/commit/%s'):format(commit),
      },
      {
        label = 'short commit',
        content = commit:sub(1, 5),
        cursors = '^',
        expect = ('https://github.com/josa42/nvim-gx/commit/%s'):format(commit),
      },
      {
        label = 'too short commit',
        content = commit:sub(1, 4),
        cursors = '^',
        expect = nil,
      },
    },
  },
  {
    filetypes = { '' },
    tests = vim.tbl_map(function(domain)
      return {
        label = ('domain "%s"'):format(domain),
        content = domain,
        cursors = '^',
        expect = ('http://%s'):format(domain),
      }
    end, domains),
  },
  {
    filetypes = { '' },
    tests = vim.tbl_map(function(url)
      return {
        label = ('url "%s"'):format(url),
        content = url,
        cursors = '^',
        expect = nil,
        expect_warn = ('No url found for "%s"'):format(url),
      }
    end, not_urls),
  },
  {
    filetypes = { 'javascript', 'typescript' },
    -- filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    tests = {
      {
        label = 'import-from (express)',
        content = 'import express from "express"',
        cursors = '^      ^       ^    ^^',
        expect = 'https://www.npmjs.com/package/express',
      },
      {
        label = 'import-from named (express)',
        content = 'import { m } from "express"',
        cursors = '^      ^ ^   ^    ^^',
        expect = 'https://www.npmjs.com/package/express',
      },
      {
        label = 'import (express)',
        content = 'import "express"',
        cursors = '^      ^^',
        expect = 'https://www.npmjs.com/package/express',
      },
      {
        label = 'dynamic import (express)',
        content = 'import("express")',
        cursors = '^     ^^^',
        expect = 'https://www.npmjs.com/package/express',
      },
      {
        label = 'dynamic import await (express)',
        content = 'await import("express")',
        cursors = '^     ^     ^^^',
        expect = 'https://www.npmjs.com/package/express',
      },
      {
        label = 'dynamic import assign (express)',
        content = 'const p = import("express")',
        cursors = '^     ^ ^ ^     ^^^',
        expect = 'https://www.npmjs.com/package/express',
      },
      {
        label = 'dynamic import assign await (express)',
        content = 'const p = await import("express")',
        cursors = '^     ^ ^ ^     ^     ^^^',
        expect = 'https://www.npmjs.com/package/express',
      },
      {
        label = 'require (express)',
        content = 'require("express")',
        cursors = '^      ^^^',
        expect = 'https://www.npmjs.com/package/express',
      },
      {
        label = 'require assign (express)',
        content = 'const m = require("express")',
        cursors = '^     ^ ^ ^      ^^^',
        expect = 'https://www.npmjs.com/package/express',
      },
      {
        label = 'import-from (@babel/core)',
        content = 'import babel from "@babel/core"',
        cursors = '       ^     ^    ^^',
        expect = 'https://www.npmjs.com/package/@babel/core',
      },
      {
        label = 'import (@babel/core)',
        content = 'import "@babel/core"',
        cursors = '^      ^^',
        expect = 'https://www.npmjs.com/package/@babel/core',
      },
      {
        label = 'dynamic import (@babel/core)',
        content = 'import("@babel/core")',
        cursors = '^     ^^^',
        expect = 'https://www.npmjs.com/package/@babel/core',
      },
      {
        label = 'dynamic import await (@babel/core)',
        content = 'await import("@babel/core")',
        cursors = '^     ^     ^^^',
        expect = 'https://www.npmjs.com/package/@babel/core',
      },
      {
        label = 'dynamic import assign (@babel/core)',
        content = 'const p = import("@babel/core")',
        cursors = '^     ^ ^ ^     ^^^',
        expect = 'https://www.npmjs.com/package/@babel/core',
      },
      {
        label = 'dynamic import assign await (@babel/core)',
        content = 'const p = await import("@babel/core")',
        cursors = '^     ^ ^ ^     ^     ^^^',
        expect = 'https://www.npmjs.com/package/@babel/core',
      },
      {
        label = 'require (@babel/core)',
        content = 'require("@babel/core")',
        cursors = '^      ^^^',
        expect = 'https://www.npmjs.com/package/@babel/core',
      },
      {
        label = 'require assign (@babel/core)',
        content = 'const m = require("@babel/core")',
        cursors = '^     ^ ^ ^      ^^^',
        expect = 'https://www.npmjs.com/package/@babel/core',
      },
    },
  },
  {
    filetypes = { 'markdown' },
    tests = {
      {
        label = 'link',
        content = '[example](https://example.org?foo=1)',
        cursors = '^^      ^^^                   ^  ^^',
        expect = 'https://example.org?foo=1',
      },
      {
        label = 'link without protocol',
        content = '[example](example.org/index.html?foo=1)',
        cursors = '^',
        expect = 'https://example.org/index.html?foo=1',
      },
      {
        label = 'link with alias',
        content = '[example][example_label]\n[example_label]: example.org/index.html?foo=1',
        cursors = '^^      ^^^            ^      ',
        expect = 'https://example.org/index.html?foo=1',
      },
      {
        label = 'unresolvable link (/path)',
        content = '[example](/path)',
        cursors = '^',
        expect = nil,
      },
      {
        label = 'unresolvable link (#hash)',
        content = '[example](#hash)',
        cursors = '^',
        expect = nil,
      },
      {
        label = 'unresolvable link (mailto:foo@example.org)',
        content = '[example](mailto:foo@example.org)',
        cursors = '^',
        expect = nil,
      },
      {
        label = 'empty link',
        content = '[example]()',
        cursors = '^',
        expect = nil,
      },
      {
        label = 'empty line',
        content = '',
        cursors = '^',
        expect = nil,
      },
    },
  },
}

local function cursor_list(cur)
  local l = {}
  for i = 1, #cur do
    local c = cur:sub(i, i)
    if c == '^' then
      table.insert(l, { 1, i - 1 })
    end
  end
  return l
end

describe('gx', function()
  local gx
  local gx_os

  before_each(function()
    vim.cmd.enew()

    package.loaded['gx'] = nil
    package.loaded['gx.os'] = nil

    gx = require('gx')
    gx_os = require('gx.os')

    gx_os.open = spy.new(function() end)
    vim.notify = spy.new(function() end)
  end)

  describe('gx()', function()
    for _, case in ipairs(cases) do
      for _, filetype in ipairs(case.filetypes) do
        describe(filetype ~= '' and 'in a ' .. filetype .. ' buffer' or 'in a buffer', function()
          for _, s in ipairs(case.tests) do
            describe('- with ' .. s.label .. ' syntax', function()
              for _, cursor in ipairs(cursor_list(s.cursors)) do
                it(
                  (s.expect ~= nil and 'should open url cursor at ' or 'should NOT open url cursor at ')
                    .. vim.inspect(cursor[2]),
                  function()
                    vim.api.nvim_buf_set_option(0, 'filetype', filetype)
                    vim.api.nvim_buf_set_lines(0, 0, -1, true, vim.fn.split(s.content, '\n'))
                    vim.api.nvim_win_set_cursor(0, cursor)

                    gx.gx()
                    vim.wait(100)

                    if s.expect ~= nil then
                      assert.spy(gx_os.open).was.called_with(s.expect)
                    else
                      assert.spy(gx_os.open).was_not.called()
                    end

                    if s.expect_warn then
                      assert.spy(vim.notify).was.called_with(s.expect_warn, vim.log.levels.WARN)
                    end
                  end
                )
              end
            end)
          end
        end)
      end
    end
  end)

  describe('check_if_valid_url()', function()
    for _, url in ipairs(urls) do
      it(('should identify valid url "%s"'):format(url), function()
        assert.is_true(gx.check_if_valid_url(url))
      end)
    end
  end)
end)
