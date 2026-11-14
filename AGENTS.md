# AGENTS.md

This repo is a Neovim nightly (0.13) config for reading and reviewing agent-written code, built with [nixvim](https://github.com/nix-community/nixvim). README.md describes the layout, plugins, load triggers and keys. Read it before a change.

## Rules

- Everything is a nixvim option in `modules/`: plugins and their settings, options, keymaps, language servers, formatters and tools. Raw Lua (`lib.nixvim.mkRaw`, `extraConfigLua*`, `luaConfig`) only where nixvim has no option, with a comment saying why.
- Search the nixvim source at the pinned revision (`nix flake metadata`, then `plugins/by-name/<name>/default.nix`) for an option before writing Lua. Plugins with a nixvim module use it; `extraPlugins` is for a plugin nixvim lacks (Flexoki).
- Startup gate: `hyperfine -N -w 5 -r 60 'result/bin/nvim --headless +qa' 'result/bin/nvim --headless init.lua +qa'` on aardvark (any Lua file of about 90 lines) stays at or under 40 ms. A new plugin is lazy unless it draws the first screen or must hook Neovim before the first file opens; give it an lz.n trigger through `lazyLoad.settings` (cmd, ft, keys, event or `lazy = true`). Measure before and after with the command above, and read `instr` from `hyperfine --export-json` when the host is loaded.
- A lazy plugin's key goes in `plugins.lz-n.keymaps` in `keymaps.nix` with its plugin name from `lzName`; Lua that requires a lazy plugin outside its own setup calls `require('lz.n').trigger_load` first (see the start screen and the Neogit and Octo `before` hooks).
- Language servers start on DeferredUIEnter (`lsp.luaConfig` in `languages.nix`). A headless smoke check fires it: `vim.api.nvim_exec_autocmds('User', { pattern = 'DeferredUIEnter' })` after VimEnter.
- Do not use Mason or runtime installs. Every server, formatter and CLI the config calls is in the `nvim-language-tools` or `nvim-cli-tools` environment; server modules set `package = null`.
- `performance.combinePlugins` merges the start plugins into one directory. A build error "two given paths contain a conflicting subpath" names a plugin to add to `standalonePlugins`.
- Check Neovim APIs against `:help news` and the runtime docs of the installed nightly, not memory. 0.13 is unreleased and changes weekly.
- After a change, run `nix build`, then in a Rex pane open a file of each touched language: treesitter is active, the LSP clients attach, `:messages` is empty, and each touched key or command loads its plugin. Then run `:checkhealth vim.lsp blink.cmp conform fff octo render-markdown nvim-treesitter`. Plugins without a health check (fzf-lua, gitsigns, lz.n, mini, oil) report "No healthcheck found"; nvim-treesitter's install directory warning is expected, since Nix supplies the parsers.
- Alt-h/j/k/l navigation spans two repos: `navigate` in `modules/keymaps.nix` and the `focus_*_or_neovim` actions in dots' Rex configuration. Change them together.
- A change is not done until README.md matches it.
