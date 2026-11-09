local osc52 = require('vim.ui.clipboard.osc52')

local function paste_unnamed()
  return { vim.fn.getreg('"', 1, true), vim.fn.getregtype('"') }
end

-- Linux hosts are servers the Mac reaches through Rex or SSH, with no desktop
-- clipboard. A Rex block there has no SSH variables, so the OS decides. Copies travel to the Mac as OSC 52;
-- pastes read the unnamed register, since a terminal may not answer OSC 52
-- reads.
local terminal_clipboard = {
  name = 'OSC 52 copy, local paste',
  copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
  paste = { ['+'] = paste_unnamed, ['*'] = paste_unnamed },
}

return {
  g = {
    mapleader = ' ',
    maplocalleader = ' ',
    loaded_nvim_dir_plugin = 1,
    clipboard = vim.fn.has('linux') == 1 and terminal_clipboard or nil,
  },

  o = {
    number = true,
    relativenumber = true,
    signcolumn = 'yes',
    cursorline = true,
    scrolloff = 8,
    sidescrolloff = 8,
    wrap = false,
    list = true,
    listchars = 'tab:» ,trail:·,nbsp:␣',
    winborder = 'rounded',
    pumheight = 12,

    showmode = false,

    splitright = true,
    splitbelow = true,
    confirm = true,
    undofile = true,
    swapfile = false,
    updatetime = 250,
    timeoutlen = 400,
    clipboard = 'unnamedplus',

    ignorecase = true,
    smartcase = true,
    inccommand = 'split',

    expandtab = true,
    shiftwidth = 2,
    tabstop = 2,
    breakindent = true,

    foldmethod = 'expr',
    foldexpr = 'v:lua.vim.treesitter.foldexpr()',
    foldtext = '',
    foldlevelstart = 99,
  },

  diagnostic = {
    severity_sort = true,
    virtual_text = { current_line = true },
    float = { source = true },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = 'E',
        [vim.diagnostic.severity.WARN] = 'W',
        [vim.diagnostic.severity.INFO] = 'I',
        [vim.diagnostic.severity.HINT] = 'H',
      },
    },
  },
}
