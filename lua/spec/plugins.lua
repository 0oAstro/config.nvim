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
      require('kanagawa').setup({ background = { dark = 'wave', light = 'lotus' } })
      vim.cmd.colorscheme('kanagawa')
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
    src = gh('stevearc/conform.nvim'),
    setup = function()
      require('conform').setup({
        formatters_by_ft = languages.formatters_by_ft,
        default_format_opts = { lsp_format = 'fallback' },
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
  {
    src = gh('nvim-treesitter/nvim-treesitter-context'),
    setup = function()
      require('treesitter-context').setup({ max_lines = 3 })
    end,
  },
  {
    src = gh('MeanderingProgrammer/render-markdown.nvim'),
    setup = function()
      require('render-markdown').setup({ latex = { enabled = false } })
    end,
  },
  {
    src = gh('esmuellert/codediff.nvim'),
    setup = function()
      require('codediff').setup({})
    end,
  },
  { packadd = 'nvim.undotree' },
  { packadd = 'nvim.difftool' },
}
