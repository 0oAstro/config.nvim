-- Keymaps beyond Neovim's defaults. LSP keys are the built-in ones
-- (grn, gra, grr, gri, grt, gO, K) and stay unmapped here.

---@alias KeymapRow { [1]: string|string[], [2]: string, [3]: string|function, [4]: string }

local function fzf(picker)
  return function()
    require('fzf-lua')[picker]()
  end
end

local function fff(action)
  return function()
    require('fff')[action]()
  end
end

local function harpoon_select(index)
  return function()
    require('harpoon'):list():select(index)
  end
end

-- Alt-h/j/k/l moves to the Neovim window that way, or past Neovim's edge to
-- the Rex block that way. Rex sends these keys into a block that runs Neovim
-- (dots: rex/init.lua), so the same keys work in both directions.
local function navigate(letter, direction)
  return function()
    local before = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(letter)
    if vim.api.nvim_get_current_win() == before and vim.env.REX_BIN_DIR then
      vim.system({ vim.env.REX_BIN_DIR .. '/rex', 'focus', direction })
    end
  end
end

local function flash(action)
  return function()
    require('flash')[action]()
  end
end

local function gitsigns(action, ...)
  local args = { ... }
  return function()
    require('gitsigns')[action](unpack(args))
  end
end

---@type KeymapRow[]
return {
  { 'n', '<leader>f', fff('find_files'), 'Find files' },
  { 'n', '<leader>/', fff('live_grep'), 'Grep project' },
  { { 'n', 'x' }, '<leader>*', fff('live_grep_under_cursor'), 'Grep word or selection' },
  { 'n', '<leader>b', fzf('buffers'), 'Buffers' },
  { 'n', '<leader>o', fzf('oldfiles'), 'Recent files' },
  { 'n', '<leader>h', fzf('helptags'), 'Help' },
  { 'n', '<leader>k', fzf('keymaps'), 'Keymaps' },
  { 'n', '<leader>r', fzf('resume'), 'Resume last picker' },
  { 'n', '<leader>s', fzf('lsp_document_symbols'), 'Document symbols' },
  { 'n', '<leader>S', fzf('lsp_live_workspace_symbols'), 'Workspace symbols' },
  { 'n', '<leader>d', fzf('diagnostics_document'), 'Buffer diagnostics' },
  { 'n', '<leader>D', fzf('diagnostics_workspace'), 'Workspace diagnostics' },
  { 'n', '<leader>gg', '<Cmd>Neogit<CR>', 'Neogit' },
  { 'n', '<leader>gs', fzf('git_status'), 'Git status' },
  { 'n', '<leader>gl', fzf('git_commits'), 'Git log' },
  { 'n', '<leader>gd', '<Cmd>CodeDiff<CR>', 'Diff working tree' },
  { 'n', '<leader>gh', '<Cmd>CodeDiff history<CR>', 'Diff history' },

  { 'n', ']h', gitsigns('nav_hunk', 'next'), 'Next hunk' },
  { 'n', '[h', gitsigns('nav_hunk', 'prev'), 'Previous hunk' },
  { 'n', '<leader>gp', gitsigns('preview_hunk_inline'), 'Preview hunk' },
  { 'n', '<leader>ga', gitsigns('stage_hunk'), 'Stage or unstage hunk' },
  { 'n', '<leader>gr', gitsigns('reset_hunk'), 'Reset hunk' },
  { 'n', '<leader>gb', gitsigns('blame_line', { full = true }), 'Blame line' },
  {
    { 'n', 'x' },
    '<leader>go',
    function()
      require('snacks').gitbrowse()
    end,
    'Open on GitHub',
  },

  {
    'n',
    '<leader>e',
    function()
      require('snacks').explorer()
    end,
    'File tree',
  },

  {
    'n',
    '<leader>ma',
    function()
      require('harpoon'):list():add()
    end,
    'Mark file',
  },
  {
    'n',
    '<leader>mm',
    function()
      local harpoon = require('harpoon')
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end,
    'Marked files',
  },
  { 'n', '<leader>1', harpoon_select(1), 'Marked file 1' },
  { 'n', '<leader>2', harpoon_select(2), 'Marked file 2' },
  { 'n', '<leader>3', harpoon_select(3), 'Marked file 3' },
  { 'n', '<leader>4', harpoon_select(4), 'Marked file 4' },

  { 'n', '<leader>xx', '<Cmd>Trouble diagnostics toggle<CR>', 'Diagnostics' },
  { 'n', '<leader>xb', '<Cmd>Trouble diagnostics toggle filter.buf=0<CR>', 'Buffer diagnostics' },
  { 'n', '<leader>xs', '<Cmd>Trouble symbols toggle<CR>', 'Symbols outline' },
  { 'n', '<leader>xr', '<Cmd>Trouble lsp toggle<CR>', 'LSP references and definitions' },
  { 'n', '<leader>xq', '<Cmd>Trouble qflist toggle<CR>', 'Quickfix list' },

  { 'n', '<leader>gP', '<Cmd>Octo pr list<CR>', 'GitHub pull requests' },
  { 'n', '<leader>gI', '<Cmd>Octo issue list<CR>', 'GitHub issues' },
  { 'n', '<leader>gR', '<Cmd>Octo review<CR>', 'Review the current pull request' },

  { 'n', '<M-h>', navigate('h', 'left'), 'Window or Rex block left' },
  { 'n', '<M-j>', navigate('j', 'down'), 'Window or Rex block below' },
  { 'n', '<M-k>', navigate('k', 'up'), 'Window or Rex block above' },
  { 'n', '<M-l>', navigate('l', 'right'), 'Window or Rex block right' },

  { { 'n', 'x', 'o' }, 's', flash('jump'), 'Jump (flash)' },
  { { 'n', 'x', 'o' }, 'S', flash('treesitter'), 'Select a treesitter node (flash)' },

  {
    'n',
    ']t',
    function()
      require('todo-comments').jump_next()
    end,
    'Next TODO',
  },
  {
    'n',
    '[t',
    function()
      require('todo-comments').jump_prev()
    end,
    'Previous TODO',
  },
  { 'n', '<leader>xt', '<Cmd>Trouble todo toggle<CR>', 'TODO list' },

  { 'n', '-', '<Cmd>Oil<CR>', 'Parent directory' },
  { 'n', '<leader>u', '<Cmd>Undotree<CR>', 'Undo tree' },
  {
    { 'n', 'x' },
    '<leader>=',
    function()
      require('conform').format({ async = true })
    end,
    'Format',
  },
  {
    'n',
    '<leader>i',
    function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end,
    'Toggle inlay hints',
  },
  { 'n', '<Esc>', '<Cmd>nohlsearch<CR>', 'Clear search highlight' },
}
