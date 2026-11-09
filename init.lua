-- The whole config reads top to bottom. lua/spec/ holds the data; this file
-- applies it in one fixed order. No plugin/ directory, no lazy loading.

local options = require('spec.options')
local plugins = require('spec.plugins')
local languages = require('spec.languages')
local keymaps = require('spec.keymaps')

for name, value in pairs(options.g) do
  vim.g[name] = value
end
for name, value in pairs(options.o) do
  vim.o[name] = value
end
vim.diagnostic.config(options.diagnostic)

require('vim._core.ui2').enable({})

local builds = {}
local pack_specs = {}
for _, plugin in ipairs(plugins) do
  if plugin.src then
    local spec = { src = plugin.src, version = plugin.version }
    table.insert(pack_specs, spec)
    builds[vim.fn.fnamemodify(plugin.src, ':t')] = plugin.build
  end
end

vim.api.nvim_create_autocmd('PackChanged', {
  desc = 'Run a plugin build after vim.pack installs or updates it',
  callback = function(event)
    local name, kind = event.data.spec.name, event.data.kind
    local build = builds[name]
    if build and (kind == 'install' or kind == 'update') then
      build()
    end
  end,
})

vim.pack.add(pack_specs)

for _, plugin in ipairs(plugins) do
  if plugin.packadd then
    vim.cmd.packadd(plugin.packadd)
  end
  if plugin.setup then
    plugin.setup()
  end
end

for name, config in pairs(languages.servers) do
  vim.lsp.config(name, config)
end
vim.lsp.enable(vim.tbl_keys(languages.servers))

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Start treesitter for every declared language',
  pattern = languages.filetypes,
  callback = function(event)
    local lang = vim.treesitter.language.get_lang(event.match)
    if lang and vim.treesitter.language.add(lang) then
      vim.treesitter.start(event.buf, lang)
    end
  end,
})

for _, map in ipairs(keymaps) do
  vim.keymap.set(map[1], map[2], map[3], { desc = map[4] })
end

vim.api.nvim_create_autocmd({ 'TextYankPost', 'TextPutPost' }, {
  desc = 'Flash yanked and put text',
  callback = function()
    vim.hl.hl_op({ higroup = 'Visual', timeout = 200 })
  end,
})

vim.api.nvim_create_autocmd({ 'ModeChanged', 'DiagnosticChanged' }, {
  desc = 'Redraw the statusline for its mode glyph and diagnostic counts',
  callback = function()
    vim.cmd.redrawstatus()
  end,
})
