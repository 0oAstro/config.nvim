-- Keymaps beyond Neovim's defaults. LSP keys are the built-in ones
-- (grn, gra, grr, gri, grt, gO, K) and stay unmapped here.

local function fzf(picker)
  return function()
    require('fzf-lua')[picker]()
  end
end

local function gitsigns(action, ...)
  local args = { ... }
  return function()
    require('gitsigns')[action](unpack(args))
  end
end

return {
  { 'n', '<leader>f', fzf('files'), 'Find files' },
  { 'n', '<leader>/', fzf('live_grep'), 'Grep project' },
  { 'n', '<leader>*', fzf('grep_cword'), 'Grep word under cursor' },
  { 'n', '<leader>b', fzf('buffers'), 'Buffers' },
  { 'n', '<leader>o', fzf('oldfiles'), 'Recent files' },
  { 'n', '<leader>h', fzf('helptags'), 'Help' },
  { 'n', '<leader>k', fzf('keymaps'), 'Keymaps' },
  { 'n', '<leader>r', fzf('resume'), 'Resume last picker' },
  { 'n', '<leader>s', fzf('lsp_document_symbols'), 'Document symbols' },
  { 'n', '<leader>S', fzf('lsp_live_workspace_symbols'), 'Workspace symbols' },
  { 'n', '<leader>d', fzf('diagnostics_document'), 'Buffer diagnostics' },
  { 'n', '<leader>D', fzf('diagnostics_workspace'), 'Workspace diagnostics' },
  { 'n', '<leader>gs', fzf('git_status'), 'Git status' },
  { 'n', '<leader>gl', fzf('git_commits'), 'Git log' },

  { 'n', ']h', gitsigns('nav_hunk', 'next'), 'Next hunk' },
  { 'n', '[h', gitsigns('nav_hunk', 'prev'), 'Previous hunk' },
  { 'n', '<leader>gp', gitsigns('preview_hunk_inline'), 'Preview hunk' },
  { 'n', '<leader>ga', gitsigns('stage_hunk'), 'Stage or unstage hunk' },
  { 'n', '<leader>gr', gitsigns('reset_hunk'), 'Reset hunk' },
  { 'n', '<leader>gb', gitsigns('blame_line', { full = true }), 'Blame line' },

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
