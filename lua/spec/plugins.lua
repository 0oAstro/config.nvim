-- Plugins in load order. `src` entries come through vim.pack and the lockfile;
-- `packadd` entries ship with Neovim. `setup` runs once, right after every
-- plugin is on the runtimepath. `build` runs after vim.pack updates the plugin.

local languages = require('spec.languages')

local function gh(repo)
  return 'https://github.com/' .. repo
end

return {
  {
    src = gh('rebelot/kanagawa.nvim'),
    setup = function()
      require('kanagawa').setup({ compile = false })
      vim.cmd.colorscheme('kanagawa-wave')
    end,
  },
  {
    src = gh('nvim-mini/mini.nvim'),
    setup = function()
      require('mini.icons').setup()
      MiniIcons.mock_nvim_web_devicons()
      require('mini.ai').setup()
      require('mini.surround').setup()
    end,
  },
  {
    src = gh('nvim-treesitter/nvim-treesitter'),
    version = 'main',
    setup = function()
      require('nvim-treesitter').install(languages.parsers)
    end,
    build = function()
      vim.cmd('TSUpdate')
    end,
  },
  {
    src = gh('neovim/nvim-lspconfig'),
  },
  {
    src = gh('saghen/blink.cmp'),
    version = vim.version.range('1.*'),
    setup = function()
      require('blink.cmp').setup({
        keymap = { preset = 'default' },
        completion = { documentation = { auto_show = true } },
        signature = { enabled = true },
        fuzzy = { implementation = 'prefer_rust_with_warning' },
      })
    end,
  },
  {
    src = gh('stevearc/conform.nvim'),
    setup = function()
      require('conform').setup({
        formatters_by_ft = languages.formatters_by_ft,
        format_on_save = { timeout_ms = 1000, lsp_format = 'fallback' },
      })
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
  {
    src = gh('ibhagwan/fzf-lua'),
    setup = function()
      require('fzf-lua').setup({ 'default-title' })
      require('fzf-lua').register_ui_select()
    end,
  },
  {
    src = gh('stevearc/oil.nvim'),
    setup = function()
      require('oil').setup({
        default_file_explorer = true,
        view_options = { show_hidden = true },
      })
    end,
  },
  {
    src = gh('lewis6991/gitsigns.nvim'),
    setup = function()
      require('gitsigns').setup()
    end,
  },
  { packadd = 'nvim.undotree' },
  { packadd = 'nvim.difftool' },
}
