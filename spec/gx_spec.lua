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

local not_urls = {
  '',
  'foo',
  'example.org',
}

describe('gx', function()
  local gx

  before_each(function()
    package.loaded['gx'] = nil
    gx = require('gx')
    gx.open = spy.new(function() end)
  end)

  describe('gx())', function()
    for _, url in ipairs(urls) do
      it('should open url "' .. url .. '"', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { url })

        gx.gx()

        assert.spy(gx.open).was.called_with(url)
      end)
    end

    for _, repo in ipairs(repos) do
      it('should open repo "' .. repo .. '"', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { repo })

        gx.gx()

        assert.spy(gx.open).was.called_with('https://github.com/' .. repo)
      end)
    end

    for _, url in ipairs(not_urls) do
      it('should NOT open url "' .. url .. '"', function()
        vim.api.nvim_buf_set_lines(0, 0, -1, true, { url })

        gx.gx()

        assert.spy(gx.open).was_not.called_with(match._)
      end)
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
