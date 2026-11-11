{
  pkgs,
  lib,
  neovim-nightly,
  ...
}:
{
  neovim = neovim-nightly;

  initLua = ''
    vim.g.nix = true
  '';

  luaFiles = [ ./init.lua ];

  plugins.dev.config-nvim = {
    pure = lib.fileset.toSource {
      root = ./.;
      fileset = ./lua;
    };
    impure = "~/Developer/config.nvim";
  };

  plugins.start = with pkgs.vimPlugins; [
    kanagawa-nvim
    plenary-nvim
    mini-nvim
    nvim-treesitter.withAllGrammars
    nvim-treesitter-context
    nvim-lspconfig
    blink-cmp
    conform-nvim
    snacks-nvim
    fzf-lua
    fff-nvim
    harpoon2
    oil-nvim
    gitsigns-nvim
    codediff-nvim
    neogit
    trouble-nvim
    octo-nvim
    todo-comments-nvim
    flash-nvim
    quicker-nvim
    render-markdown-nvim
  ];

  extraBinPath = with pkgs; [
    git
    gh
    ripgrep
    fd
    fzf

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
}
