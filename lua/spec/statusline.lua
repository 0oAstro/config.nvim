-- A statusline in the style of the Pure zsh prompt (and the p10k-pure config
-- in dots): no separators or background blocks, colored text only.
-- user@host (on a remote host only, as Pure shows it over SSH), path, git branch with `*` when the file has
-- unstaged hunks, then the virtualenv. The mode glyph comes first, the way
-- Pure shows ❯ in insert and ❮ in vi command mode; it turns red when the
-- buffer has errors, as Pure's ❯ does after a failed command.

local host = require('spec.host')

local function paint(group, text)
  return '%#' .. group .. '#' .. text .. '%*'
end

local mode_glyphs = {
  n = '❮',
  i = '❯',
  v = 'V',
  V = 'V',
  ['\22'] = 'V',
  c = ':',
  R = '▶',
  t = '$',
}

local function mode_glyph(buf)
  local glyph = mode_glyphs[vim.fn.mode():sub(1, 1)] or '❮'
  local errors = #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.ERROR })
  return paint(errors > 0 and 'DiagnosticError' or 'Statement', glyph)
end

local function context()
  if not host.remote then
    return nil
  end
  return paint('Comment', vim.env.USER .. '@' .. vim.uv.os_gethostname())
end

local function path(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local shown = name == '' and '[No Name]' or vim.fn.fnamemodify(name, ':~:.')
  local flag = vim.bo[buf].modified and ' +' or (vim.bo[buf].readonly and ' ro' or '')
  return paint('Directory', shown) .. paint('Comment', flag)
end

local function git(buf)
  local head = vim.b[buf].gitsigns_head
  if not head or head == '' then
    return nil
  end
  local status = vim.b[buf].gitsigns_status_dict or {}
  local dirty = (status.added or 0) + (status.changed or 0) + (status.removed or 0) > 0
  return paint('Comment', head) .. (dirty and paint('Special', '*') or '')
end

local function virtualenv()
  local env = vim.env.VIRTUAL_ENV
  return env and paint('Comment', vim.fn.fnamemodify(env, ':t')) or nil
end

local function diagnostics(buf)
  local parts = {}
  local severities = {
    { severity = vim.diagnostic.severity.ERROR, group = 'DiagnosticError', letter = 'E' },
    { severity = vim.diagnostic.severity.WARN, group = 'DiagnosticWarn', letter = 'W' },
  }
  for _, row in ipairs(severities) do
    local count = #vim.diagnostic.get(buf, { severity = row.severity })
    if count > 0 then
      table.insert(parts, paint(row.group, row.letter .. count))
    end
  end
  return #parts > 0 and table.concat(parts, ' ') or nil
end

local function join(...)
  local present = {}
  for i = 1, select('#', ...) do
    local item = select(i, ...)
    if item then
      table.insert(present, item)
    end
  end
  return table.concat(present, ' ')
end

return function()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)
  local active = win == vim.api.nvim_get_current_win()
  local left = join(active and mode_glyph(buf) or ' ', context(), path(buf), git(buf), virtualenv())
  local right = join(diagnostics(buf), paint('Comment', '%l:%c'))
  return ' ' .. left .. '%=' .. right .. ' '
end
