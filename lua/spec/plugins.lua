-- Plugins in load order. `src` entries come through vim.pack and the lockfile;
-- `packadd` entries ship with Neovim. `setup` runs once, right after every
-- plugin is on the runtimepath. `build` runs after vim.pack installs or
-- updates the plugin, before it is loaded, so it loads what it needs itself.

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
  { src = gh('nvim-lua/plenary.nvim') },
  {
    src = gh('nvim-mini/mini.nvim'),
    setup = function()
      local icons = require('mini.icons')
      icons.setup()
      icons.mock_nvim_web_devicons()
      require('mini.ai').setup()
      require('mini.surround').setup()

      local clue = require('mini.clue')
      clue.setup({
        triggers = {
          { mode = 'n', keys = '<Leader>' },
          { mode = 'x', keys = '<Leader>' },
          { mode = 'n', keys = 'g' },
          { mode = 'x', keys = 'g' },
          { mode = 'n', keys = '[' },
          { mode = 'n', keys = ']' },
          { mode = 'n', keys = 'z' },
          { mode = 'n', keys = '<C-w>' },
          { mode = 'n', keys = "'" },
          { mode = 'n', keys = '"' },
          { mode = 'i', keys = '<C-r>' },
        },
        clues = {
          clue.gen_clues.g(),
          clue.gen_clues.square_brackets(),
          clue.gen_clues.z(),
          clue.gen_clues.windows(),
          clue.gen_clues.marks(),
          clue.gen_clues.registers(),
          { mode = 'n', keys = '<Leader>c', desc = '+claude' },
          { mode = 'x', keys = '<Leader>c', desc = '+claude' },
          { mode = 'n', keys = '<Leader>g', desc = '+git' },
          { mode = 'n', keys = '<Leader>m', desc = '+marks (harpoon)' },
          { mode = 'n', keys = '<Leader>x', desc = '+trouble' },
        },
        window = { delay = 300 },
      })
    end,
  },
  {
    src = gh('nvim-treesitter/nvim-treesitter'),
    version = 'main',
    setup = function()
      require('nvim-treesitter').install(languages.parsers)
    end,
    build = function()
      vim.cmd.packadd('nvim-treesitter')
      vim.cmd('TSUpdate')
    end,
  },
  {
    src = gh('nvim-treesitter/nvim-treesitter-context'),
    setup = function()
      require('treesitter-context').setup({ max_lines = 3 })
    end,
  },
  { src = gh('neovim/nvim-lspconfig') },
  { src = gh('saghen/blink.lib') },
  {
    src = gh('saghen/blink.cmp'),
    version = 'main',
    setup = function()
      require('blink.cmp').setup({
        keymap = { preset = 'default' },
        completion = { documentation = { auto_show = true } },
        signature = { enabled = true },
        fuzzy = { implementation = 'rust' },
      })
    end,
    build = function()
      vim.cmd.packadd('blink.lib')
      vim.cmd.packadd('blink.cmp')
      require('blink.cmp').build():pwait()
    end,
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
    src = gh('folke/snacks.nvim'),
    setup = function()
      require('snacks').setup({
        bigfile = { enabled = true },
        indent = { enabled = true },
        words = { enabled = true },
        input = { enabled = true },
        explorer = { enabled = true, replace_netrw = false },
        picker = { enabled = true, ui_select = false },
      })
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
    src = gh('dmtrKovalenko/fff'),
    setup = function()
      require('fff').setup({})
    end,
    build = function()
      vim.cmd.packadd('fff')
      require('fff.download').download_or_build_binary()
    end,
  },
  {
    src = gh('ThePrimeagen/harpoon'),
    version = 'harpoon2',
    setup = function()
      require('harpoon'):setup()
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
    src = gh('esmuellert/codediff.nvim'),
    setup = function()
      require('codediff').setup({})
    end,
  },
  {
    src = gh('NeogitOrg/neogit'),
    setup = function()
      require('neogit').setup({
        diff_viewer = 'codediff',
        integrations = { codediff = true, fzf_lua = true },
      })
    end,
  },
  {
    src = gh('folke/trouble.nvim'),
    setup = function()
      require('trouble').setup({})
    end,
  },
  {
    src = gh('coder/claudecode.nvim'),
    setup = function()
      require('claudecode').setup({ terminal = { provider = 'none' } })
    end,
  },
  {
    src = gh('MeanderingProgrammer/render-markdown.nvim'),
    setup = function()
      require('render-markdown').setup({ latex = { enabled = false } })
    end,
  },
  { packadd = 'nvim.undotree' },
  { packadd = 'nvim.difftool' },
}
