# config.nvim

Neovim config for Neovim nightly (0.13). Agents write most of the code and the Markdown, so this config is built for reading and reviewing their output: navigation, diffs, PR review, rendered Markdown, and LSP. Agents run beside it in Rex blocks, and Alt-h/j/k/l moves between Neovim windows and Rex blocks alike. It uses the built-in plugin manager (`vim.pack`) and the built-in LSP client.

The repo is also a Nix flake. Its package is Neovim nightly wrapped with this config, every plugin, all treesitter grammars, and every language server, formatter and CLI the config calls. [0oAstro/dots](https://github.com/0oAstro/dots) installs that package as `nvim`. Any machine with Nix runs it without installing anything:

```sh
nix run github:0oAstro/config.nvim
```

A plain clone in `~/.config/nvim` still works without Nix: `vim.pack` installs the plugins from `nvim-pack-lock.json`, and the binaries must be on `PATH`.

## Nix and plain modes

| | Nix package | Plain clone |
| --- | --- | --- |
| Neovim | nightly from [neovim-nightly-overlay](https://github.com/nix-community/neovim-nightly-overlay) | whatever `nvim` is on `PATH`; it must be nightly |
| Plugins | `plugins.start` in `config.nix`, at nixpkgs' versions, built by Nix | `plugins.lua` through `vim.pack` at the `nvim-pack-lock.json` revisions |
| Treesitter parsers | every grammar in nixpkgs | the `parsers` of `languages.lua`, compiled by nvim-treesitter |
| Language tools | `extraBinPath` in `config.nix`, appended to `PATH` | `PATH` only |
| State directories | `NVIM_APPNAME=mnw`: `~/.local/share/mnw`, `~/.local/state/mnw` | `~/.local/share/nvim`, `~/.local/state/nvim` |

The wrapper ([mnw](https://github.com/Gerg-L/mnw)) sets `vim.g.nix = true` before `init.lua` runs. `init.lua` skips `vim.pack` and the build hooks when it is set, and the nvim-treesitter setup skips parser installs. Nothing else reads it.

Plugin versions differ between the modes. nixpkgs ships blink.cmp 1.x where `vim.pack` tracks the v2 `main` branch, and blink.lib is unused in the Nix package. The rest follow nixpkgs' revisions, which are close to the lockfile but not equal to it.

`nix run .#default.devMode` in a checkout at `~/Developer/config.nvim` reads `lua/` from the checkout instead of the store, so an edit there takes effect at the next start without a rebuild. `init.lua` is still read from the store; an edit to it needs `nix run .`.

## Layout

| File | Holds |
| --- | --- |
| `init.lua` | The only code that runs. It applies the specs below in one fixed order. |
| `lua/spec/options.lua` | `vim.g` and `vim.o` values and the diagnostic config. |
| `lua/spec/plugins.lua` | Plugins in load order, each with an optional `setup` and `build`. |
| `lua/spec/languages.lua` | One entry per language: filetypes, treesitter parsers, LSP servers, formatters. |
| `lua/spec/keymaps.lua` | Keymaps as `{ mode, lhs, rhs, desc }` rows. |
| `nvim-pack-lock.json` | Plugin revisions for the plain clone, written by `vim.pack`. |
| `flake.nix` | The `default` package and a dev shell with lua-language-server, stylua and nixfmt. |
| `config.nix` | mnw's settings for the package: Neovim, plugins, grammars and `extraBinPath`. |
| `flake.lock` | Revisions of nixpkgs, mnw and the Neovim nightly. |

The config has no `plugin/` directory, no `after/` directory, and no lazy loading. Every behavior traces back to a row in a spec.

## Plugins

| Plugin | Job |
| --- | --- |
| [kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim) | Colorscheme: wave when the terminal is dark, lotus when it is light. |
| [mini.nvim](https://github.com/nvim-mini/mini.nvim) | `mini.icons`, `mini.ai` text objects, `mini.surround` (on `gs`, since flash owns `s`), `mini.clue` key hints, and `mini.statusline`. |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (main) | Parser install. Highlighting, folds and selection are built into Neovim. |
| [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) | Keeps the enclosing function and class on screen while you scroll. |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Server definitions only. `vim.lsp.enable` starts them. |
| [blink.cmp](https://github.com/saghen/blink.cmp) v2 (main) and [blink.lib](https://github.com/saghen/blink.lib) | Completion and signature help. The Rust matcher builds with cargo on install. |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Formatting on demand with `<leader>=`. Nothing formats on save. |
| [fff](https://github.com/dmtrKovalenko/fff) | File search and grep: typo-resistant, ranked by frecency and git status, with a background index. |
| [fzf-lua](https://github.com/ibhagwan/fzf-lua) | Every other picker: buffers, help, symbols, diagnostics, git log, keymaps, and `vim.ui.select`. |
| [snacks.nvim](https://github.com/folke/snacks.nvim) | Start screen, file tree (explorer), indent guides, LSP reference highlight, big-file guard, `vim.ui.input`, open on GitHub. Its picker serves only the explorer. |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | Directory buffers that edit the file system. |
| [harpoon](https://github.com/ThePrimeagen/harpoon) (harpoon2) | A short list of marked files, one key each. Needs [plenary.nvim](https://github.com/nvim-lua/plenary.nvim). |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Hunk signs, inline hunk preview, staging and blame. |
| [neogit](https://github.com/NeogitOrg/neogit) | Git status, staging, commits, branches and log, with codediff for diffs. |
| [codediff.nvim](https://github.com/esmuellert/codediff.nvim) | Side-by-side review of the working tree, a revision, or the history. |
| [trouble.nvim](https://github.com/folke/trouble.nvim) | Lists for diagnostics, references, symbols and quickfix. |
| [octo.nvim](https://github.com/pwntester/octo.nvim) | GitHub pull requests and issues: read the diff, comment, review, approve. Uses the `gh` login. |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlights and lists TODO, FIXME, HACK and NOTE comments. |
| [flash.nvim](https://github.com/folke/flash.nvim) | Jump to any visible spot with `s` and a label; `S` selects a treesitter node. |
| [quicker.nvim](https://github.com/stevearc/quicker.nvim) | A cleaner quickfix list that you can edit to change the matched lines. |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Renders Markdown headings, tables, lists and code blocks in the buffer. |

Neovim also ships `nvim.undotree` and `nvim.difftool`, which `plugins.lua` loads with `packadd`.

The statusline is `mini.statusline` with its defaults: a mode block colored by mode, then git branch, diff counts, diagnostics and LSP clients, the file name, file info, and the cursor position. Sections collapse as the window narrows.

Built-in features cover the rest:
- `'autoread'` watches files, so a buffer shows an agent's edit as soon as it is written.
- The theme follows the terminal. Neovim reads Rex's background (lotus while the Mac is in light mode), and a terminal that reports theme changes (DEC mode 2031) switches it live.
- On a remote host, yanks to `+` go to the Mac as OSC 52 through Rex.

## Common changes

Add a language: add an entry to `lua/spec/languages.lua`, then add its server and formatter packages to `extraBinPath` in `config.nix`. The Nix package already has every grammar.

Add a plugin: add a row to `lua/spec/plugins.lua` and its `pkgs.vimPlugins` attribute to `plugins.start` in `config.nix`. In a plain clone, `:restart` makes `vim.pack` install it and record the revision in `nvim-pack-lock.json`; commit the lockfile.

Remove a plugin: delete its row and its `config.nix` attribute. In a plain clone, `:restart`, then `:packdel <name>`, and commit the lockfile.

Update the Nix package: `nix flake update` here, push, then `just pins` (or `tack update nvim-config`) in dots and switch.

Update a plain clone: run `:packupdate`, review the diff in the tab that opens, then `:write` to accept. Commit `nvim-pack-lock.json`. On another plain clone, `git pull` and `:packupdate ++lockfile` move the plugins to its revisions.

Check the setup: `:checkhealth vim.pack vim.lsp blink.cmp conform fff octo render-markdown nvim-treesitter`. In the Nix package, nvim-treesitter reports that its install directory is not in `runtimepath`; that is expected, since Nix supplies the parsers.

## Keys

The leader key is Space. LSP keys are Neovim's defaults: `grn` rename, `gra` code action, `grr` references, `gri` implementation, `grt` type definition, `gO` symbols, `K` hover. `<leader>k` searches every keymap.

| Key | Action |
| --- | --- |
| `<leader>f` `<leader>/` `<leader>*` | Find files, grep, grep word or selection (fff) |
| `<leader>b` `<leader>o` `<leader>h` `<leader>r` | Buffers, recent files, help, resume (fzf-lua) |
| `<leader>s` `<leader>S` | Document and workspace symbols |
| `<leader>d` `<leader>D` | Buffer and workspace diagnostics |
| `<leader>e` `-` | File tree (snacks), parent directory (oil) |
| `<leader>ma` `<leader>mm` `<leader>1`..`<leader>4` | Mark a file, list marks, jump to a mark (harpoon) |
| `<leader>gg` `<leader>gd` `<leader>gh` | Neogit, diff the working tree, diff history |
| `<leader>gs` `<leader>gl` `<leader>go` | Git status, git log, open on GitHub |
| `]h` `[h` `<leader>gp` `<leader>ga` `<leader>gr` `<leader>gb` | Next and previous hunk, preview, stage, reset, blame |
| `<leader>xx` `<leader>xb` `<leader>xs` `<leader>xr` `<leader>xq` | Trouble: diagnostics, buffer diagnostics, symbols, LSP, quickfix |
| `<M-h>` `<M-j>` `<M-k>` `<M-l>` | Move to the Neovim window that way, or on to the Rex block past Neovim's edge |
| `s` `S` | Flash jump, flash treesitter selection |
| `]t` `[t` `<leader>xt` | Next and previous TODO, TODO list |
| `<leader>gP` `<leader>gI` `<leader>gR` | GitHub pull requests, issues, review the current PR (octo) |
| `gsa` `gsd` `gsr` | Add, delete, replace surrounding characters |
| `<leader>u` `<leader>=` `<leader>i` | Undo tree, format, inlay hints |

Alt-h/j/k/l works across Rex because dots binds the same keys in Rex's `init.lua`. A Rex block running Neovim gets the key; any other block moves Rex focus. Opening Neovim with no file shows the start screen: find, grep, recent files, Neogit, diff and the file tree, one key each.

## C++ for competitive programming

A `.cpp` file outside a project compiles as GCC C++20, so `#include <bits/stdc++.h>` resolves in clangd. dots sets this in clangd's user config. The Nix package ships clangd and clang-format from nixpkgs' clang-tools. Compile with `gcc14-g++` on Linux and `g++-16` on macOS. Apple clang has no `bits/stdc++.h`.
