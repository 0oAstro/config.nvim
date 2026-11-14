# Keymaps beyond Neovim's defaults. LSP keys are the built-in ones (grn, gra,
# grr, gri, grt, gO, K) and stay unmapped here. A key under lazy is bound
# through lz.n, which loads its plugin on the first press.
{ config, lib, ... }:
let
  inherit (lib.nixvim) mkRaw;
  lzName = plugin: lib.getName config.plugins.${plugin}.package;

  map = mode: key: action: desc: {
    inherit mode key action;
    options.desc = desc;
  };
  lazy = plugin: mode: key: action: desc: {
    plugin = lzName plugin;
    inherit mode key action;
    options.desc = desc;
  };

  call = lua: mkRaw "function() ${lua} end";
  fzf = picker: call "require('fzf-lua').${picker}()";
  fff = action: call "require('fff').${action}()";
  gitsigns = action: call "require('gitsigns').${action}";
  harpoonSelect = index: call "require('harpoon'):list():select(${toString index})";

  # Alt-h/j/k/l moves to the Neovim window that way, or past Neovim's edge to
  # the Rex block that way. Rex sends these keys into a block that runs
  # Neovim (dots: the Rex module), so the same keys work in both directions.
  navigate =
    letter: direction:
    mkRaw ''
      function()
        local before = vim.api.nvim_get_current_win()
        vim.cmd.wincmd('${letter}')
        if vim.api.nvim_get_current_win() == before and vim.env.REX_BIN_DIR then
          vim.system({ vim.env.REX_BIN_DIR .. '/rex', 'focus', '${direction}' })
        end
      end
    '';

  nx = [
    "n"
    "x"
  ];
  nxo = [
    "n"
    "x"
    "o"
  ];
in
{
  keymaps = [
    (map "n" "<leader>gg" "<Cmd>Neogit<CR>" "Neogit")
    (map "n" "<leader>gd" "<Cmd>CodeDiff<CR>" "Diff working tree")
    (map "n" "<leader>gh" "<Cmd>CodeDiff history<CR>" "Diff history")
    (map nx "<leader>go" (call "require('snacks').gitbrowse()") "Open on GitHub")
    (map "n" "<leader>e" (call "require('snacks').explorer()") "File tree")

    (map "n" "<leader>xx" "<Cmd>Trouble diagnostics toggle<CR>" "Diagnostics")
    (map "n" "<leader>xb" "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>" "Buffer diagnostics")
    (map "n" "<leader>xs" "<Cmd>Trouble symbols toggle<CR>" "Symbols outline")
    (map "n" "<leader>xr" "<Cmd>Trouble lsp toggle<CR>" "LSP references and definitions")
    (map "n" "<leader>xq" "<Cmd>Trouble qflist toggle<CR>" "Quickfix list")
    (map "n" "<leader>xt" "<Cmd>Trouble todo toggle<CR>" "TODO list")

    (map "n" "<leader>gP" "<Cmd>Octo pr list<CR>" "GitHub pull requests")
    (map "n" "<leader>gI" "<Cmd>Octo issue list<CR>" "GitHub issues")
    (map "n" "<leader>gR" "<Cmd>Octo review<CR>" "Review the current pull request")

    (map "n" "<M-h>" (navigate "h" "left") "Window or Rex block left")
    (map "n" "<M-j>" (navigate "j" "down") "Window or Rex block below")
    (map "n" "<M-k>" (navigate "k" "up") "Window or Rex block above")
    (map "n" "<M-l>" (navigate "l" "right") "Window or Rex block right")

    (map "n" "-" "<Cmd>Oil<CR>" "Parent directory")
    (map "n" "<leader>u" "<Cmd>Undotree<CR>" "Undo tree")
    (map nx "<leader>=" (call "require('conform').format({ async = true })") "Format")
    (map "n" "<leader>i" (call "vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())")
      "Toggle inlay hints"
    )
    (map "n" "<Esc>" "<Cmd>nohlsearch<CR>" "Clear search highlight")
  ];

  plugins.lz-n.keymaps = [
    (lazy "fff" "n" "<leader>f" (fff "find_files") "Find files")
    (lazy "fff" "n" "<leader>/" (fff "live_grep") "Grep project")
    (lazy "fff" nx "<leader>*" (fff "live_grep_under_cursor") "Grep word or selection")

    (lazy "fzf-lua" "n" "<leader>b" (fzf "buffers") "Buffers")
    (lazy "fzf-lua" "n" "<leader>o" (fzf "oldfiles") "Recent files")
    (lazy "fzf-lua" "n" "<leader>h" (fzf "helptags") "Help")
    (lazy "fzf-lua" "n" "<leader>k" (fzf "keymaps") "Keymaps")
    (lazy "fzf-lua" "n" "<leader>r" (fzf "resume") "Resume last picker")
    (lazy "fzf-lua" "n" "<leader>s" (fzf "lsp_document_symbols") "Document symbols")
    (lazy "fzf-lua" "n" "<leader>S" (fzf "lsp_live_workspace_symbols") "Workspace symbols")
    (lazy "fzf-lua" "n" "<leader>d" (fzf "diagnostics_document") "Buffer diagnostics")
    (lazy "fzf-lua" "n" "<leader>D" (fzf "diagnostics_workspace") "Workspace diagnostics")
    (lazy "fzf-lua" "n" "<leader>gs" (fzf "git_status") "Git status")
    (lazy "fzf-lua" "n" "<leader>gl" (fzf "git_commits") "Git log")

    (lazy "gitsigns" "n" "]h" (gitsigns "nav_hunk('next')") "Next hunk")
    (lazy "gitsigns" "n" "[h" (gitsigns "nav_hunk('prev')") "Previous hunk")
    (lazy "gitsigns" "n" "<leader>gp" (gitsigns "preview_hunk_inline()") "Preview hunk")
    (lazy "gitsigns" "n" "<leader>ga" (gitsigns "stage_hunk()") "Stage or unstage hunk")
    (lazy "gitsigns" "n" "<leader>gr" (gitsigns "reset_hunk()") "Reset hunk")
    (lazy "gitsigns" "n" "<leader>gb" (gitsigns "blame_line({ full = true })") "Blame line")

    (lazy "harpoon" "n" "<leader>ma" (call "require('harpoon'):list():add()") "Mark file")
    (lazy "harpoon" "n" "<leader>mm"
      (call "require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())")
      "Marked files"
    )
    (lazy "harpoon" "n" "<leader>1" (harpoonSelect 1) "Marked file 1")
    (lazy "harpoon" "n" "<leader>2" (harpoonSelect 2) "Marked file 2")
    (lazy "harpoon" "n" "<leader>3" (harpoonSelect 3) "Marked file 3")
    (lazy "harpoon" "n" "<leader>4" (harpoonSelect 4) "Marked file 4")

    (lazy "flash" nxo "s" (call "require('flash').jump()") "Jump (flash)")
    (lazy "flash" nxo "S" (call "require('flash').treesitter()") "Select a treesitter node (flash)")

    (lazy "todo-comments" "n" "]t" (call "require('todo-comments').jump_next()") "Next TODO")
    (lazy "todo-comments" "n" "[t" (call "require('todo-comments').jump_prev()") "Previous TODO")
  ];
}
