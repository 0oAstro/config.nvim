# config.nvim

Neovim config for Neovim nightly (0.13). It uses only the built-in plugin manager (`vim.pack`), the built-in LSP client, and nine plugins.

chezmoi in [0oAstro/dots](https://github.com/0oAstro/dots) clones this repo to `~/.config/nvim` and installs every binary it calls through mise.

## Layout

| File | Holds |
| --- | --- |
| `init.lua` | The only code that runs. It applies the four specs below in one fixed order. |
| `lua/spec/options.lua` | `vim.g` and `vim.o` values and the diagnostic config. |
| `lua/spec/plugins.lua` | Plugins in load order, each with an optional `setup` and `build`. |
| `lua/spec/languages.lua` | One entry per language: filetypes, treesitter parsers, LSP servers, formatters. |
| `lua/spec/keymaps.lua` | Keymaps as `{ mode, lhs, rhs, desc }` rows. |
| `nvim-pack-lock.json` | Plugin revisions, written by `vim.pack`. |

The config has no `plugin/` directory, no `after/` directory, and no lazy loading. Every behavior traces back to a row in a spec.

## Plugins

| Plugin | Job |
| --- | --- |
| kanagawa.nvim | Colorscheme. It matches the kanagawa tmux theme. |
| mini.nvim | `mini.icons`, `mini.ai` text objects, and `mini.surround`. |
| nvim-treesitter (main) | Parser install. Highlighting, folds and selection are built into Neovim. |
| nvim-lspconfig | Server definitions only. `vim.lsp.enable` starts them. |
| blink.cmp | Completion and signature help. |
| conform.nvim | Format on save, with LSP formatting as the fallback. |
| fzf-lua | Every picker. It also replaces `vim.ui.select`. |
| oil.nvim | Directory buffers that edit the file system. |
| gitsigns.nvim | Hunk signs, staging and blame. |

Neovim also ships `nvim.undotree` and `nvim.difftool`, which `plugins.lua` loads with `packadd`.

## Common changes

Add a language: add an entry to `lua/spec/languages.lua`, then add its server and formatter binaries to `home/private_dot_config/mise/conf.d/core.toml` in dots.

Add a plugin: add a row to `lua/spec/plugins.lua` and restart with `:restart`. `vim.pack` installs it and records the revision in `nvim-pack-lock.json`.

Update plugins: run `:packupdate`, review the diff in the tab that opens, then `:write` to accept. Commit `nvim-pack-lock.json`. On the other machine, `chezmoi update` pulls the lockfile and `:packupdate ++lockfile` moves the plugins to its revisions.

Check the setup: `:checkhealth vim.pack vim.lsp conform blink.cmp nvim-treesitter`.

## Keys

The leader key is Space. LSP keys are Neovim's defaults: `grn` rename, `gra` code action, `grr` references, `gri` implementation, `grt` type definition, `gO` symbols, `K` hover. `<leader>k` searches every keymap.

| Key | Action |
| --- | --- |
| `<leader>f` `<leader>/` `<leader>*` | Files, grep, grep word |
| `<leader>b` `<leader>o` `<leader>h` `<leader>r` | Buffers, recent files, help, resume |
| `<leader>s` `<leader>S` | Document and workspace symbols |
| `<leader>d` `<leader>D` | Buffer and workspace diagnostics |
| `<leader>gs` `<leader>gl` | Git status, git log |
| `]h` `[h` `<leader>gp` `<leader>ga` `<leader>gr` `<leader>gb` | Next and previous hunk, preview, stage, reset, blame |
| `-` | Parent directory (oil) |
| `<leader>u` `<leader>=` `<leader>i` | Undo tree, format, inlay hints |

## C++ for competitive programming

A `.cpp` file outside a project compiles as GCC C++20, so `#include <bits/stdc++.h>` resolves in clangd. dots sets this in clangd's user config. Compile with `gcc14-g++` on Linux and `g++-16` on macOS. Apple clang has no `bits/stdc++.h`.
