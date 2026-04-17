local M = {}

-- Resolves GitHub Actions 'uses' references in workflow files.
-- Works with both .yml and .yaml file extensions.
-- Supports:
--   - Workflow files: uses: owner/repo/.github/workflows/file.yml@main
--   - Actions with path: uses: owner/repo/actions/name@v1.0.0
--   - Actions without path: uses: google-github-actions/auth@v2
function M.get_url(word)
  -- Parse the current line to extract the uses reference
  local line = vim.api.nvim_get_current_line()

  -- Extract the content after "uses: " (with optional quotes)
  local uses_content = line:match('uses:%s*["\']?([^"\'%s]+)["\']?')
  if not uses_content or uses_content == '' then
    return false
  end

  -- Reject local paths and docker images
  if uses_content:match('^%.%.?/') or uses_content:match('^docker://') then
    return false
  end

  -- Find the last @ character to split ref from path
  local last_at = nil
  for i = #uses_content, 1, -1 do
    if uses_content:sub(i, i) == '@' then
      last_at = i
      break
    end
  end

  if not last_at then
    return false
  end

  local path_part = uses_content:sub(1, last_at - 1)
  local ref = uses_content:sub(last_at + 1)

  -- Count the number of / in path_part to determine structure
  local slash_count = 0
  for char in path_part:gmatch('/') do
    slash_count = slash_count + 1
  end

  local owner, repo, path

  if slash_count == 1 then
    -- Simple case: owner/repo (no path component)
    owner, repo = path_part:match('^([^/]+)/([^/]+)$')
    path = nil
  elseif slash_count >= 2 then
    -- Complex case: owner/repo/path/...
    owner, repo, path = path_part:match('^([^/]+)/([^/]+)(/.*)$')
  else
    return false
  end

  if not owner or not repo then
    return false
  end

  -- Construct the GitHub URL
  local url = ('https://github.com/%s/%s/blob/%s'):format(owner, repo, ref)

  if path then
    url = url .. path
  end

  -- For workflow files, don't append action.yml
  -- For everything else (actions or custom paths), append /action.yml
  if not path or not path:match('^/.github/workflows/') then
    url = url .. '/action.yml'
  end

  return true, url
end

return M
