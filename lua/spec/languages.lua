-- Each language names its filetypes, treesitter parsers, LSP servers (with
-- settings) and conform formatters. 0oAstro/dots installs every server and
-- formatter binary: mise for most; dnf on Linux, Xcode and Homebrew on macOS
-- for clangd and clang-format.

local plain = {
  'toml',
  'sql',
  'swift',
  'dockerfile',
  'make',
  'gitcommit',
  'gitignore',
  'diff',
  'regex',
  'vim',
  'vimdoc',
  'query',
}

local languages = {
  {
    filetypes = { 'lua' },
    parsers = { 'lua', 'luadoc' },
    servers = {
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
          },
        },
      },
    },
    formatters = { 'stylua' },
  },
  {
    filetypes = { 'python' },
    parsers = { 'python' },
    servers = { ty = {}, ruff = {} },
    formatters = { 'ruff_organize_imports', 'ruff_format' },
  },
  {
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    parsers = { 'javascript', 'jsdoc', 'typescript', 'tsx' },
    servers = { tsc = {}, oxlint = {} },
    formatters = { 'oxfmt' },
  },
  {
    filetypes = { 'astro' },
    parsers = { 'astro' },
    servers = { astro = {} },
    formatters = {},
  },
  {
    filetypes = { 'go', 'gomod', 'gosum' },
    parsers = { 'go', 'gomod', 'gosum' },
    servers = { gopls = {} },
    formatters = {},
  },
  {
    filetypes = { 'c', 'cpp' },
    parsers = { 'c', 'cpp' },
    servers = {
      clangd = {
        cmd = { 'clangd', '--query-driver=/usr/bin/gcc14-g++,/opt/homebrew/bin/g++-*' },
      },
    },
    formatters = { 'clang-format' },
  },
  {
    filetypes = { 'rust' },
    parsers = { 'rust' },
    servers = { rust_analyzer = {} },
    formatters = { 'rustfmt' },
  },
  {
    filetypes = { 'sh', 'bash', 'zsh' },
    parsers = { 'bash', 'zsh' },
    servers = { bashls = {} },
    formatters = { 'shfmt' },
  },
  {
    filetypes = { 'markdown' },
    parsers = { 'markdown', 'markdown_inline' },
    servers = { marksman = {} },
    formatters = {},
  },
  {
    filetypes = { 'html', 'css', 'json', 'jsonc', 'yaml' },
    parsers = { 'html', 'css', 'json', 'yaml' },
    servers = {},
    formatters = { 'oxfmt' },
  },
  { filetypes = plain, parsers = plain, servers = {}, formatters = {} },
}

local function collect(field)
  local items = {}
  for _, language in ipairs(languages) do
    vim.list_extend(items, language[field])
  end
  return items
end

local function servers()
  local all = {}
  for _, language in ipairs(languages) do
    for name, config in pairs(language.servers) do
      all[name] = config
    end
  end
  return all
end

local function formatters_by_ft()
  local by_ft = {}
  for _, language in ipairs(languages) do
    if #language.formatters > 0 then
      for _, filetype in ipairs(language.filetypes) do
        by_ft[filetype] = language.formatters
      end
    end
  end
  return by_ft
end

return {
  filetypes = collect('filetypes'),
  parsers = collect('parsers'),
  servers = servers(),
  formatters_by_ft = formatters_by_ft(),
}
