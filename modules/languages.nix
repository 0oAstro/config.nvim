# Language servers and formatters. Treesitter highlights every filetype that
# has a grammar (plugins.nix); nothing here starts it.
{ lib, pkgs, ... }:
let
  # Server binaries come from the language tool environment below.
  server = config: {
    enable = true;
    package = null;
    inherit config;
  };
  withOxfmt = [ "oxfmt" ];
in
{
  plugins.lspconfig.enable = true;

  # Servers start right after the first screen draws (lz.n's DeferredUIEnter);
  # vim.lsp.enable then attaches them to the buffers already open. Starting a
  # client loads most of vim.lsp, about 12 ms. blink.cmp loads on the same
  # event first (plugins.nix), so every client gets its capabilities.
  lsp.luaConfig = {
    pre = ''
      vim.api.nvim_create_autocmd('User', {
        pattern = 'DeferredUIEnter',
        once = true,
        desc = 'Configure and enable the language servers',
        callback = function()
    '';
    post = ''
        end,
      })
    '';
  };

  lsp.servers = {
    lua_ls = server {
      settings.Lua = {
        runtime.version = "LuaJIT";
        workspace = {
          checkThirdParty = false;
          library = [ (lib.nixvim.mkRaw "vim.env.VIMRUNTIME") ];
        };
      };
    };
    ty = server { };
    ruff = server { };
    tsc = server { };
    oxlint = server { };
    astro = server { };
    gopls = server { };
    clangd = server {
      # dots names nixpkgs' GCC wrapper as the fallback compiler for loose
      # .cpp files; clangd may query it for system includes.
      cmd = [
        "clangd"
        "--query-driver=/nix/store/*-gcc-wrapper-*/bin/g++"
      ];
    };
    rust_analyzer = server { };
    bashls = server { };
    marksman = server { };
  };

  plugins.conform-nvim = {
    enable = true;
    settings = {
      formatters_by_ft = {
        lua = [ "stylua" ];
        python = [
          "ruff_organize_imports"
          "ruff_format"
        ];
        javascript = withOxfmt;
        javascriptreact = withOxfmt;
        typescript = withOxfmt;
        typescriptreact = withOxfmt;
        html = withOxfmt;
        css = withOxfmt;
        json = withOxfmt;
        jsonc = withOxfmt;
        yaml = withOxfmt;
        c = [ "clang-format" ];
        cpp = [ "clang-format" ];
        rust = [ "rustfmt" ];
        sh = [ "shfmt" ];
        bash = [ "shfmt" ];
        zsh = [ "shfmt" ];
      };
      # Nothing formats on save; <leader>= formats on demand.
      default_format_opts.lsp_format = "fallback";
    };
    luaConfig.post = ''
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    '';
  };

  # Servers, formatters and toolchains, in one PATH entry (default.nix).
  extraPackagesAfter = [
    (pkgs.buildEnv {
      name = "nvim-language-tools";
      paths = with pkgs; [
        lua-language-server
        stylua
        ty
        ruff
        typescript
        oxlint
        oxfmt
        astro-language-server
        go
        gopls
        clang-tools
        rust-analyzer
        rustfmt
        bash-language-server
        shfmt
        marksman
      ];
    })
  ];
}
