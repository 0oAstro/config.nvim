# config.nvim

Neovim config for Neovim nightly (0.13). Agents write most of the code and the Markdown, so this config is built for reading and reviewing their output: navigation, diffs, rendered Markdown, and LSP. It uses the built-in plugin manager (`vim.pack`), the built-in LSP client, built-in completion, and eleven plugins.

chezmoi in [0oAstro/dots](https://github.com/0oAstro/dots) clones this repo to `~/.config/nvim` and installs every binary it calls.

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
| [kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim) | Colorscheme: wave when the terminal is dark, lotus when it is light. |
| [mini.nvim](https://github.com/nvim-mini/mini.nvim) | `mini.icons`, `mini.ai` text objects, and `mini.surround`. |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (main) | Parser install. Highlighting, folds and selection are built into Neovim. |
| [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) | Keeps the enclosing function and class on screen while you scroll. |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Server definitions only. `vim.lsp.enable` starts them. |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Formatting on demand with `<leader>=`. Nothing formats on save. |
| [fzf-lua](https://github.com/ibhagwan/fzf-lua) | Every picker. It also replaces `vim.ui.select`. |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | Directory buffers that edit the file system. |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Hunk signs, inline hunk preview, staging and blame. |
| [codediff.nvim](https://github.com/esmuellert/codediff.nvim) | Side-by-side review of the working tree, a revision, or the history. |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Renders Markdown headings, tables, lists and code blocks in the buffer. |

Neovim also ships `nvim.undotree` and `nvim.difftool`, which `plugins.lua` loads with `packadd`.

Built-in features cover the rest:
- Completion is Neovim's `'autocomplete'` with LSP items through `'omnifunc'`. `<C-y>` accepts.
- `'autoread'` watches files, so a buffer shows an agent's edit as soon as it is written.
- The theme follows the terminal. Neovim reads the terminal background, and a terminal that reports theme changes (DEC mode 2031) switches it live.

## Common changes

Add a language: add an entry to `lua/spec/languages.lua`, then add its server and formatter binaries to `home/private_dot_config/mise/conf.d/core.toml` in dots.

Add a plugin: add a row to `lua/spec/plugins.lua` and restart with `:restart`. `vim.pack` installs it and records the revision in `nvim-pack-lock.json`.

Remove a plugin: delete its row, `:restart`, then `:packdel <name>`. Commit the lockfile.

Update plugins: run `:packupdate`, review the diff in the tab that opens, then `:write` to accept. Commit `nvim-pack-lock.json`. On the other machine, `chezmoi update --refresh-externals` pulls the lockfile and `:packupdate ++lockfile` moves the plugins to its revisions.

Check the setup: `:checkhealth vim.pack vim.lsp conform render-markdown nvim-treesitter`.

## Keys

The leader key is Space. LSP keys are Neovim's defaults: `grn` rename, `gra` code action, `grr` references, `gri` implementation, `grt` type definition, `gO` symbols, `K` hover. `<leader>k` searches every keymap.

| Key | Action |
| --- | --- |
| `<leader>f` `<leader>/` `<leader>*` | Files, grep, grep word |
| `<leader>b` `<leader>o` `<leader>h` `<leader>r` | Buffers, recent files, help, resume |
| `<leader>s` `<leader>S` | Document and workspace symbols |
| `<leader>d` `<leader>D` | Buffer and workspace diagnostics |
| `<leader>gd` `<leader>gh` | Diff the working tree, browse diff history (codediff) |
| `<leader>gs` `<leader>gl` | Git status, git log |
| `]h` `[h` `<leader>gp` `<leader>ga` `<leader>gr` `<leader>gb` | Next and previous hunk, preview, stage, reset, blame |
| `-` | Parent directory (oil) |
| `<leader>u` `<leader>=` `<leader>i` | Undo tree, format, inlay hints |

## C++ for competitive programming

A `.cpp` file outside a project compiles as GCC C++20, so `#include <bits/stdc++.h>` resolves in clangd. dots sets this in clangd's user config. Compile with `gcc14-g++` on Linux and `g++-16` on macOS. Apple clang has no `bits/stdc++.h`.
