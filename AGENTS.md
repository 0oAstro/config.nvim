# AGENTS.md

This repo is a Neovim nightly (0.13) config for reading and reviewing agent-written code. README.md describes the layout, plugins and keys. Read it before a change.

## Rules

- The specs in `lua/spec/` are data. `init.lua` is the only code that applies them, in one fixed order. Do not add `plugin/`, `after/`, `ftplugin/` or lazy loading, and do not add state that one autocmd sets and another reads.
- A language-specific behavior goes in the language's entry in `lua/spec/languages.lua`, not in a new autocmd.
- Do not use Mason. Every server and formatter binary comes from mise in 0oAstro/dots (`home/private_dot_config/mise/conf.d/core.toml`). clangd and clang-format come from dnf on Linux; on macOS clangd comes from Xcode and clang-format from Homebrew.
- `nvim-pack-lock.json` is written by `vim.pack`. Do not edit it by hand. Commit it with every plugin change.
- Check Neovim APIs against `:help news` and the runtime docs of the installed nightly, not memory. 0.13 is unreleased and changes weekly.
- After a change, start `nvim --headless` on a file of each touched language and confirm that treesitter is active, the LSP clients attach, and `:messages` is empty. Then run `:checkhealth vim.pack vim.lsp conform render-markdown nvim-treesitter`.
- A change is not done until README.md matches it.
