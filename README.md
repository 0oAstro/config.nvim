# config.nvim

Neovim config for Neovim nightly (0.13). Agents write most of the code and the Markdown, so this config is built for reading and reviewing their output: navigation, diffs, PR review, rendered Markdown, and LSP. Agents run beside it in Rex blocks, and Alt-h/j/k/l moves between Neovim windows and Rex blocks alike.

The whole config is Nix, written as [nixvim](https://github.com/nix-community/nixvim) options: plugins and their settings, options, keymaps, language servers, formatters and the tools they call. nixvim generates `init.lua` from them. The flake's package is Neovim nightly wrapped with that init, every plugin, all treesitter grammars, and every language server, formatter and CLI the config calls. `lib.mkNeovim pkgs` builds it from any nixpkgs package set; [0oAstro/dots](https://github.com/0oAstro/dots) calls it with its own `pkgs`, so its overlays and pins apply, and installs the result as `nvim`. `lib.evalNeovim pkgs` returns the evaluated nixvim configuration, for reading option values. The `default` package is `lib.mkNeovim` applied to this flake's nixpkgs. Any machine with Nix runs it without installing anything:

```sh
nix run github:0oAstro/config.nvim
```

`result/bin/nixvim-print-init` prints the generated `init.lua`. State lives under Neovim's default name: `~/.local/state/nvim` and `~/.local/share/nvim`.

## Layout

| File | Holds |
| --- | --- |
| `flake.nix` | `lib.mkNeovim` and `lib.evalNeovim`, which evaluate `modules/` against a given `pkgs`; the `default` package; a dev shell with hyperfine and nixfmt. |
| `modules/default.nix` | Neovim nightly, providers off, `vim.loader`, Lua byte compilation, combined start plugins, and the CLI tool environment. |
| `modules/options.nix` | Globals, options, diagnostics, the OSC 52 clipboard on Linux, the nightly message UI, and the yank flash. |
| `modules/languages.nix` | Language servers and their settings, formatters by filetype, and the language tool environment. |
| `modules/plugins.nix` | Every plugin with its settings and its lz.n trigger. |
| `modules/keymaps.nix` | Keymaps; keys of lazy plugins go through lz.n. |
| `flake.lock` | Revisions of nixpkgs, nixvim, the Neovim nightly and Flexoki. |

## Startup

Neovim starts the first screen with only what draws it: colors, icons, statusline, start screen, oil for a directory argument, conform's `formatexpr` and quicker. [lz.n](https://github.com/lumen-oss/lz.n) loads the rest on a command, a key, a filetype, or `DeferredUIEnter`, its event right after the first screen draws. Language servers also start on `DeferredUIEnter`, and attach to the buffers already open. A `--headless` Neovim has no UI, so it never fires `DeferredUIEnter`: plugins on that event and the language servers stay off unless a script fires the event.

`vim.loader` is on, the generated init, plugins and Neovim's runtime Lua are byte-compiled at build time, and the start plugins share one runtimepath directory (snacks and oil stay separate because their files collide with others).

Measure startup on aardvark with `hyperfine -N -w 5 -r 60 'result/bin/nvim --headless +qa' 'result/bin/nvim --headless some-file.lua +qa'`. The gate is 40 ms for both.

## Plugins

| Plugin | Loads | Job |
| --- | --- | --- |
| [flexoki-neovim](https://github.com/kepano/flexoki-neovim) | start | Colorscheme: Flexoki light or dark, following 'background'. |
| [mini.icons](https://github.com/nvim-mini/mini.icons), [mini.statusline](https://github.com/nvim-mini/mini.statusline) | start | Icons (also standing in for nvim-web-devicons) and the statusline. |
| [mini.ai](https://github.com/nvim-mini/mini.ai) | `a` `i` in visual and operator mode, `g[` `g]` | Extra text objects. |
| [mini.surround](https://github.com/nvim-mini/mini.surround) | `gs` keys | Surround on `gs`, since flash owns `s`. |
| [mini.clue](https://github.com/nvim-mini/mini.clue) | after first draw | Key hints for Leader, `g`, `[`, `]`, `z`, `<C-w>`, marks and registers. |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (main) | start | Every grammar and query in nixpkgs; highlighting starts for every filetype with a parser. Folds and selection are built into Neovim. |
| [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) | after first draw | Keeps the enclosing function and class on screen while you scroll. |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | start | Server definitions only. |
| [blink.cmp](https://github.com/saghen/blink.cmp) | after first draw, insert, cmdline | Completion and signature help, with nixpkgs' Rust matcher. |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | start | Formatting on demand with `<leader>=` and `gq`. Nothing formats on save. |
| [snacks.nvim](https://github.com/folke/snacks.nvim) | start | Start screen, file tree (explorer), indent guides, LSP reference highlight, big-file guard, `vim.ui.input`, open on GitHub. Its picker serves only the explorer. |
| [fff](https://github.com/dmtrKovalenko/fff) | after first draw, its keys | File search and grep: typo-resistant, ranked by frecency and git status, with a background index. |
| [fzf-lua](https://github.com/ibhagwan/fzf-lua) | `:FzfLua`, its keys, first `vim.ui.select` | Every other picker: buffers, help, symbols, diagnostics, git log, keymaps, and `vim.ui.select`. |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | start | Directory buffers that edit the file system. |
| [harpoon](https://github.com/ThePrimeagen/harpoon) (harpoon2) | its keys | A short list of marked files, one key each. |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | after first draw, its keys | Hunk signs, inline hunk preview, staging and blame. |
| [neogit](https://github.com/NeogitOrg/neogit) | `:Neogit` | Git status, staging, commits, branches and log, with codediff for diffs. |
| [codediff.nvim](https://github.com/esmuellert/codediff.nvim) | `:CodeDiff`, Neogit | Side-by-side review of the working tree, a revision, or the history. |
| [trouble.nvim](https://github.com/folke/trouble.nvim) | `:Trouble` | Lists for diagnostics, references, symbols, quickfix and TODOs. |
| [octo.nvim](https://github.com/pwntester/octo.nvim) | `:Octo` | GitHub pull requests and issues: read the diff, comment, review, approve. Uses the `gh` login. |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | after first draw, its keys | Highlights and lists TODO, FIXME, HACK and NOTE comments. |
| [flash.nvim](https://github.com/folke/flash.nvim) | `s` `S` | Jump to any visible spot with `s` and a label; `S` selects a treesitter node. |
| [quicker.nvim](https://github.com/stevearc/quicker.nvim) | start | A cleaner quickfix list that you can edit to change the matched lines. |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Markdown files | Renders Markdown headings, tables, lists and code blocks in the buffer. |

Neovim also ships `nvim.undotree` and `nvim.difftool`, which load on `:Undotree` and `:DiffTool`.

The statusline is `mini.statusline` with its defaults: a mode block colored by mode, then git branch, diff counts, diagnostics and LSP clients, the file name, file info, and the cursor position. Sections collapse as the window narrows.

Built-in features cover the rest:
- `'autoread'` watches files, so a buffer shows an agent's edit as soon as it is written.
- The theme follows the terminal. Neovim reads the terminal's background at start and again when the terminal reports a theme change (DEC mode 2031), and a new 'background' reloads Flexoki in the matching variant. Rex switches its light and dark themes with the Mac's appearance.
- On a Linux host, yanks to `+` go to the Mac as OSC 52 through Rex; pastes read the unnamed register.

## Languages

| Filetypes | Servers | Formatters |
| --- | --- | --- |
| lua | lua_ls | stylua |
| python | ty, ruff | ruff (organize imports, format) |
| javascript, typescript (and react) | tsc, oxlint | oxfmt |
| astro | astro | |
| go | gopls | |
| c, cpp | clangd | clang-format |
| rust | rust_analyzer | rustfmt |
| sh, bash, zsh | bashls | shfmt |
| markdown | marksman | |
| html, css, json, jsonc, yaml | | oxfmt |

Formatters without an entry fall back to the server's formatting.

## Common changes

Add a language: add its server to `lsp.servers` and its formatters to `formatters_by_ft` in `modules/languages.nix`, and its packages to the `nvim-language-tools` environment there. The package already has every grammar.

Add a plugin: enable its nixvim module (`plugins.<name>`) in `modules/plugins.nix` with its settings and an lz.n trigger, and its keys in `modules/keymaps.nix`. A plugin nixvim lacks goes in `extraPlugins`, built from a flake input.

Update: `nix flake update` here, build, check the startup gate and the smoke steps in AGENTS.md, push, then `nix run .#tack -- update nvim-config` in dots and switch.

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

Alt-h/j/k/l works across Rex because dots binds the same keys in Rex's configuration. A Rex block running Neovim gets the key; any other block moves Rex focus. Opening Neovim with no file shows the start screen: find, grep, recent files, Neogit, diff and the file tree, one key each.

## C++ for competitive programming

A `.cpp` file outside a project compiles as GCC C++20, so `#include <bits/stdc++.h>` resolves in clangd. dots sets this in clangd's user config, with nixpkgs' GCC 14 `g++` as the compiler on every host, and clangd queries it through `--query-driver=/nix/store/*-gcc-wrapper-*/bin/g++`. The package ships clangd and clang-format from nixpkgs' clang-tools. Compile with that `g++`; Apple clang has no `bits/stdc++.h`.
