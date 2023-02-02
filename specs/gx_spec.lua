local spy = require('luassert.spy')
local match = require('luassert.match')

local urls = {
  'https://example.org',
  'https://example.org/index.html',
  'https://example.org/path/index.html',
  'https://example.org/path/',
  'http://example.org',
  'ftp://example.org',
}

local repos = {
  'neovim/neovim',
}

local issues = {
  '#1',
}

local commits = {
  'b13f2e931e6f1dd98ed1e002eb3a967e13bb8ee4',
}

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

local npm_packages = {
  'express',
  '@babel/core',
}

local npm_filetypes = {
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
}

local npm_import_syntax = {
  {
    label = 'import-from',
    format = 'import express from "%s"',
    cursor = { 1, 21 },
  },
  {
    label = 'import',
    format = 'import "%s"',
    cursor = { 1, 8 },
  },
  {
    label = 'dynamic import',
    format = 'const p = import("%s")',
    cursor = { 1, 18 },
  },
  {
    label = 'require',
    format = 'require("%s")',
    cursor = { 1, 9 },
  },
}

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
    for _, url in ipairs(urls) do
      it('should open url "' .. url .. '"', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { url })

        gx.gx()
        vim.wait(100)

        assert.spy(gx_os.open).was.called_with(url)
      end)
    end

    for _, repo in ipairs(repos) do
      -- temporary skip flaky test in CI
      -- if os.getenv('GITHUB_ACTIONS') == 'true' then
      --   break
      -- end

      it('should open repo "' .. repo .. '"', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { repo })

        gx.gx()
        vim.wait(100)

        assert.spy(gx_os.open).was.called_with('https://github.com/' .. repo)
      end)
    end

    for _, issue in ipairs(issues) do
      it('should open issue "' .. issue .. '"', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { issue })

        gx.gx()
        vim.wait(100)

        assert.spy(gx_os.open).was.called_with('https://github.com/josa42/nvim-gx/issues/' .. issue:sub(2))
      end)
    end

    for _, commit in ipairs(commits) do
      it('should open commit "' .. commit .. '"', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { commit })

        gx.gx()
        vim.wait(100)

        assert.spy(gx_os.open).was.called_with('https://github.com/josa42/nvim-gx/commit/' .. commit)
      end)

      it('should open short commit "' .. commit:sub(1, 5) .. '"', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { commit:sub(1, 5) })

        gx.gx()
        vim.wait(100)

        assert.spy(gx_os.open).was.called_with('https://github.com/josa42/nvim-gx/commit/' .. commit)
      end)

      it('should does not open too short commit "' .. commit:sub(1, 4) .. '"', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { commit:sub(1, 4) })

        gx.gx()
        vim.wait(100)

        assert.spy(gx_os.open).was_not.called_with(match._)
      end)
    end

    for _, domain in ipairs(domains) do
      it('should open domain "' .. domain .. '"', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { domain })

        gx.gx()
        vim.wait(100)

        assert.spy(gx_os.open).was.called_with('http://' .. domain)
      end)
    end

    for _, url in ipairs(not_urls) do
      it('should NOT open url "' .. url .. '"', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { url })

        gx.gx()
        vim.wait(100)

        assert.spy(gx_os.open).was_not.called_with(match._)
        assert.spy(vim.notify).was.called_with(('No url found for "%s"'):format(url), vim.log.levels.WARN)
      end)
    end

    for _, filetype in ipairs(npm_filetypes) do
      describe('- with ' .. filetype .. ' filetype', function()
        for _, s in ipairs(npm_import_syntax) do
          describe('- with ' .. s.label .. ' syntax', function()
            for _, pkg in ipairs(npm_packages) do
              it('should open npm package "' .. pkg .. '"', function()
                vim.api.nvim_buf_set_option(0, 'filetype', 'javascript')
                vim.api.nvim_buf_set_lines(0, 0, -1, true, { s.format:format(pkg) })
                vim.api.nvim_win_set_cursor(0, s.cursor)

                gx.gx()
                vim.wait(100)

                assert.spy(gx_os.open).was.called_with('https://www.npmjs.com/package/' .. pkg)
              end)
            end
          end)
        end
      end)
    end
  end)

  describe('markdown links', function()
    local line = '[example](%s)'
    local links = {
      {
        url = 'https://example.org?foo=1',
        columns = { 0, 1, 8, 9, 10, 30, 34, 35 },
      },
      {
        url = 'example.org/index.html?foo=1',
        url_expected = 'https://example.org/index.html?foo=1',
        columns = { 0 },
      },
    }

    for _, l in ipairs(links) do
      describe('- with url ' .. l.url, function()
        for _, column in ipairs(l.columns) do
          describe('- at column ' .. column, function()
            it('should open', function()
              vim.api.nvim_buf_set_option(0, 'filetype', 'markdown')
              vim.api.nvim_buf_set_lines(0, 0, -1, true, { line:format(l.url) })
              vim.api.nvim_win_set_cursor(0, { 1, column })

              gx.gx()
              vim.wait(100)

              assert.spy(gx_os.open).was.called_with(l.url_expected or l.url)
            end)
          end)
        end
      end)
    end

    local unresolvable_links = {
      '/path',
      '#hash',
      'mailto:foo@example.org',
      '',
    }

    for _, link in ipairs(unresolvable_links) do
      it(('should not open a "%s"'):format(link), function()
        vim.api.nvim_buf_set_option(0, 'filetype', 'markdown')
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { line:format(link) })
        vim.api.nvim_win_set_cursor(0, { 1, 0 })

        gx.gx()
        vim.wait(100)

        assert.spy(gx_os.open).was_not.called()
      end)
    end

    it('should not open anything on an empty line', function()
      vim.api.nvim_buf_set_option(0, 'filetype', 'markdown')
      vim.api.nvim_buf_set_lines(0, 0, -1, true, { '' })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      gx.gx()
      vim.wait(100)

      assert.spy(gx_os.open).was_not.called()
    end)
  end)

  describe('check_if_valid_url()', function()
    for _, url in ipairs(urls) do
      it(('should identify valid url "%s"'):format(url), function()
        assert.is_true(gx.check_if_valid_url(url))
      end)
    end
  end)
end)
