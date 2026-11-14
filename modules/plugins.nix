# Every plugin with its settings and, for lazy ones, its lz.n triggers.
# Eager plugins draw the first screen or hook Neovim early (colors, icons,
# statusline, start screen, directory buffers, formatexpr, quickfix text).
# Lazy ones load on a command, key, filetype or event; the keys this config
# binds are in keymaps.nix. "DeferredUIEnter" is lz.n's event right after the
# first screen draws; a --headless Neovim has no UI and never fires it.
{
  config,
  flexoki-neovim,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.nixvim) mkRaw;
  # The name lz.n loads a plugin by: its directory under pack/*/opt.
  lzName = plugin: lib.getName config.plugins.${plugin}.package;
  load = plugin: "require('lz.n').trigger_load('${lzName plugin}')";
  nxo = [
    "n"
    "x"
    "o"
  ];
in
{
  plugins.lz-n.enable = true;

  # Flexoki follows 'background'. Neovim asks the terminal for its background
  # at start and again when the terminal reports a theme change (DEC mode
  # 2031), and setting 'background' reloads the colorscheme.
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      pname = "flexoki-neovim";
      version = flexoki-neovim.lastModifiedDate;
      src = flexoki-neovim;
    })
  ];
  colorscheme = "flexoki";

  plugins.mini-icons = {
    enable = true;
    mockDevIcons = true;
  };

  plugins.mini-statusline.enable = true;

  plugins.mini-ai = {
    enable = true;
    lazyLoad.settings.keys = [
      {
        __unkeyed-1 = "a";
        mode = [
          "x"
          "o"
        ];
      }
      {
        __unkeyed-1 = "i";
        mode = [
          "x"
          "o"
        ];
      }
      {
        __unkeyed-1 = "g[";
        mode = nxo;
      }
      {
        __unkeyed-1 = "g]";
        mode = nxo;
      }
    ];
  };

  # On gs, since flash owns s.
  plugins.mini-surround = {
    enable = true;
    settings.mappings = {
      add = "gsa";
      delete = "gsd";
      find = "gsf";
      find_left = "gsF";
      highlight = "gsh";
      replace = "gsr";
      update_n_lines = "gsn";
    };
    lazyLoad.settings.keys = [
      {
        __unkeyed-1 = "gsa";
        mode = [
          "n"
          "x"
        ];
      }
      "gsd"
      "gsf"
      "gsF"
      "gsh"
      "gsr"
      "gsn"
    ];
  };

  plugins.mini-clue = {
    enable = true;
    settings = {
      triggers = [
        {
          mode = "n";
          keys = "<Leader>";
        }
        {
          mode = "x";
          keys = "<Leader>";
        }
        {
          mode = "n";
          keys = "g";
        }
        {
          mode = "x";
          keys = "g";
        }
        {
          mode = "n";
          keys = "[";
        }
        {
          mode = "n";
          keys = "]";
        }
        {
          mode = "n";
          keys = "z";
        }
        {
          mode = "n";
          keys = "<C-w>";
        }
        {
          mode = "n";
          keys = "'";
        }
        {
          mode = "n";
          keys = "\"";
        }
        {
          mode = "i";
          keys = "<C-r>";
        }
      ];
      clues = [
        (mkRaw "require('mini.clue').gen_clues.g()")
        (mkRaw "require('mini.clue').gen_clues.square_brackets()")
        (mkRaw "require('mini.clue').gen_clues.z()")
        (mkRaw "require('mini.clue').gen_clues.windows()")
        (mkRaw "require('mini.clue').gen_clues.marks()")
        (mkRaw "require('mini.clue').gen_clues.registers()")
        {
          mode = "n";
          keys = "<Leader>g";
          desc = "+git";
        }
        {
          mode = "n";
          keys = "<Leader>m";
          desc = "+marks (harpoon)";
        }
        {
          mode = "n";
          keys = "<Leader>x";
          desc = "+trouble";
        }
        {
          mode = "n";
          keys = "gs";
          desc = "+surround";
        }
      ];
      window.delay = 300;
    };
    lazyLoad.settings.event = "DeferredUIEnter";
  };

  # Parsers and queries for every grammar in nixpkgs, so code blocks in any
  # language highlight. Highlighting, folds and selection are Neovim's own.
  plugins.treesitter = {
    enable = true;
    highlight = {
      enable = true;
      # Some of Neovim's own ftplugins (lua, for one) start treesitter first.
      disable = mkRaw ''
        function(_, buf)
          return vim.treesitter.highlighter.active[buf] ~= nil
        end
      '';
    };
  };

  plugins.treesitter-context = {
    enable = true;
    settings.max_lines = 3;
    lazyLoad.settings.event = "DeferredUIEnter";
  };

  plugins.blink-cmp = {
    enable = true;
    settings = {
      keymap.preset = "default";
      completion.documentation.auto_show = true;
      signature.enabled = true;
      fuzzy.implementation = "rust";
    };
    lazyLoad.settings.event = [
      "DeferredUIEnter"
      "InsertEnter"
      "CmdlineEnter"
    ];
  };

  plugins.snacks = {
    enable = true;
    settings = {
      bigfile.enabled = true;
      dashboard = {
        enabled = true;
        preset.keys = [
          {
            key = "f";
            desc = "Find file";
            action = mkRaw "function() ${load "fff"}; require('fff').find_files() end";
          }
          {
            key = "/";
            desc = "Grep";
            action = mkRaw "function() ${load "fff"}; require('fff').live_grep() end";
          }
          {
            key = "o";
            desc = "Recent files";
            action = mkRaw "function() ${load "fzf-lua"}; require('fzf-lua').oldfiles() end";
          }
          {
            key = "g";
            desc = "Neogit";
            action = ":Neogit";
          }
          {
            key = "d";
            desc = "Diff working tree";
            action = ":CodeDiff";
          }
          {
            key = "e";
            desc = "File tree";
            action = mkRaw "function() require('snacks').explorer() end";
          }
          {
            key = "q";
            desc = "Quit";
            action = ":qa";
          }
        ];
        sections = [
          { section = "header"; }
          {
            section = "keys";
            gap = 1;
            padding = 1;
          }
          {
            title = "Recent in this directory";
            section = "recent_files";
            cwd = true;
            limit = 8;
            padding = 1;
          }
        ];
      };
      indent.enabled = true;
      words.enabled = true;
      input.enabled = true;
      explorer = {
        enabled = true;
        replace_netrw = false;
      };
      # Its picker serves only the explorer; fzf-lua owns vim.ui.select.
      picker = {
        enabled = true;
        ui_select = false;
      };
    };
  };

  plugins.fzf-lua = {
    enable = true;
    settings.__unkeyed-1 = "default-title";
    luaConfig.post = "require('fzf-lua').register_ui_select()";
    lazyLoad.settings.cmd = "FzfLua";
  };

  plugins.fff = {
    enable = true;
    settings = { };
    # Loaded after the first draw so its background index is warm by the
    # first search.
    lazyLoad.settings.event = "DeferredUIEnter";
  };

  plugins.harpoon = {
    enable = true;
    lazyLoad.settings.lazy = true;
  };

  # Eager: oil must own a directory given at start before netrw and the
  # start screen see it.
  plugins.oil = {
    enable = true;
    settings = {
      default_file_explorer = true;
      view_options.show_hidden = true;
    };
  };

  plugins.gitsigns = {
    enable = true;
    lazyLoad.settings.event = "DeferredUIEnter";
  };

  plugins.codediff = {
    enable = true;
    settings = { };
    lazyLoad.settings.cmd = "CodeDiff";
  };

  plugins.neogit = {
    enable = true;
    settings = {
      diff_viewer = "codediff";
      integrations = {
        codediff = true;
        fzf_lua = true;
      };
    };
    lazyLoad.settings = {
      cmd = "Neogit";
      before = mkRaw "function() ${load "codediff"}; ${load "fzf-lua"} end";
    };
  };

  plugins.trouble = {
    enable = true;
    lazyLoad.settings.cmd = "Trouble";
  };

  plugins.octo = {
    enable = true;
    settings.picker = "fzf-lua";
    lazyLoad.settings = {
      cmd = "Octo";
      before = mkRaw "function() ${load "fzf-lua"} end";
    };
  };

  plugins.todo-comments = {
    enable = true;
    lazyLoad.settings.event = "DeferredUIEnter";
  };

  plugins.flash = {
    enable = true;
    lazyLoad.settings.lazy = true;
  };

  plugins.quicker.enable = true;

  plugins.render-markdown = {
    enable = true;
    settings.latex.enabled = false;
    lazyLoad.settings.ft = "markdown";
  };

  # Optional packages that ship with Neovim.
  plugins.lz-n.plugins = [
    {
      __unkeyed-1 = "nvim.undotree";
      cmd = "Undotree";
    }
    {
      __unkeyed-1 = "nvim.difftool";
      cmd = "DiffTool";
    }
  ];

  # Load fzf-lua on the first vim.ui.select call; its setup then replaces
  # this function with its own picker.
  extraConfigLua = ''
    vim.ui.select = function(...)
      ${load "fzf-lua"}
      return vim.ui.select(...)
    end
  '';
}
