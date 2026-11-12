# AGENTS.md

This repo is a Neovim nightly (0.13) config for reading and reviewing agent-written code. README.md describes the layout, plugins and keys. Read it before a change.

## Rules

- The specs in `lua/spec/` are data. `init.lua` is the only code that applies them, in one fixed order. Do not add `plugin/`, `after/`, `ftplugin/` or lazy loading, and do not add state that one autocmd sets and another reads.
- A language-specific behavior goes in the language's entry in `lua/spec/languages.lua`, not in a new autocmd.
- Do not use Mason. Every server, formatter and CLI the config calls is a package in `extraBinPath` in `config.nix`. A plain clone expects them on `PATH`.
- A plugin lives in two places: its row in `plugins.lua` and its `pkgs.vimPlugins` attribute in `config.nix`. Change both together.
- `vim.g.nix`, set by the mnw wrapper, is the only switch between the Nix package and a plain clone. It gates `vim.pack` in `init.lua` and parser installs in the nvim-treesitter setup. Do not read it anywhere else.
- A plugin with a native part declares a `build` in `plugins.lua` for the plain clone. The build runs before the plugin loads, so it loads what it needs with `packadd`. The Nix package uses nixpkgs' build instead.
- `nvim-pack-lock.json` is written by `vim.pack`. Do not edit it by hand. Commit it with every plugin change.
- Check Neovim APIs against `:help news` and the runtime docs of the installed nightly, not memory. 0.13 is unreleased and changes weekly.
- After a change, run `nix build`, then start `result/bin/nvim --headless` on a file of each touched language and confirm that treesitter is active, the LSP clients attach, and `:messages` is empty. Then run `:checkhealth vim.pack vim.lsp blink.cmp conform fff octo render-markdown nvim-treesitter`. snacks, neogit and trouble report errors for modules this config does not enable or for a missing healthcheck, and nvim-treesitter reports that its install directory is not in `runtimepath` because Nix supplies the parsers; those are expected.
- Alt-h/j/k/l navigation spans two repos: `navigate` in `lua/spec/keymaps.lua` and the `focus_*_or_neovim` actions in dots' `config/home/rex/init.lua`. Change them together.
- A change is not done until README.md matches it.
