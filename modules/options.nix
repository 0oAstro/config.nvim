{ lib, pkgs, ... }:
{
  globals = {
    mapleader = " ";
    maplocalleader = " ";
    # oil.nvim owns directory buffers.
    loaded_nvim_dir_plugin = 1;
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    # Linux hosts are servers the Mac reaches through Rex or SSH, with no
    # desktop clipboard. Copies travel to the Mac as OSC 52; pastes read the
    # unnamed register, since a terminal may not answer OSC 52 reads. The
    # OSC 52 module loads on the first copy.
    clipboard = lib.nixvim.mkRaw ''
      (function()
        local function copy(register)
          return function(lines, regtype)
            require('vim.ui.clipboard.osc52').copy(register)(lines, regtype)
          end
        end
        local function paste_unnamed()
          return { vim.fn.getreg('"', 1, true), vim.fn.getregtype('"') }
        end
        return {
          name = 'OSC 52 copy, local paste',
          copy = { ['+'] = copy('+'), ['*'] = copy('*') },
          paste = { ['+'] = paste_unnamed, ['*'] = paste_unnamed },
        }
      end)()
    '';
  };

  opts = {
    number = true;
    relativenumber = true;
    signcolumn = "yes";
    cursorline = true;
    scrolloff = 8;
    sidescrolloff = 8;
    wrap = false;
    list = true;
    listchars = "tab:» ,trail:·,nbsp:␣";
    winborder = "rounded";
    pumheight = 12;

    showmode = false;

    splitright = true;
    splitbelow = true;
    confirm = true;
    undofile = true;
    swapfile = false;
    updatetime = 250;
    timeoutlen = 400;
    clipboard = "unnamedplus";

    ignorecase = true;
    smartcase = true;
    inccommand = "split";

    expandtab = true;
    shiftwidth = 2;
    tabstop = 2;
    breakindent = true;

    foldmethod = "expr";
    foldexpr = "v:lua.vim.treesitter.foldexpr()";
    foldtext = "";
    foldlevelstart = 99;
  };

  diagnostic.settings = {
    severity_sort = true;
    virtual_text.current_line = true;
    float.source = true;
    signs.text = {
      "__rawKey__vim.diagnostic.severity.ERROR" = "E";
      "__rawKey__vim.diagnostic.severity.WARN" = "W";
      "__rawKey__vim.diagnostic.severity.INFO" = "I";
      "__rawKey__vim.diagnostic.severity.HINT" = "H";
    };
  };

  autoCmd = [
    {
      event = [
        "TextYankPost"
        "TextPutPost"
      ];
      desc = "Flash yanked and put text";
      callback = lib.nixvim.mkRaw ''
        function()
          vim.hl.hl_op({ higroup = 'Visual', timeout = 200 })
        end
      '';
    }
  ];

  # The nightly message and cmdline UI. nixvim has no option for it.
  extraConfigLuaPre = ''
    require('vim._core.ui2').enable({})
  '';
}
