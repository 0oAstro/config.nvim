{
  config,
  lib,
  neovim-nightly,
  pkgs,
  ...
}:
{
  imports = [
    ./options.nix
    ./languages.nix
    ./plugins.nix
    ./keymaps.nix
  ];

  package = neovim-nightly;

  # nixvim's option manual is not part of the editor; building it evaluates
  # nixvim's documentation on every switch.
  enableMan = false;

  # No remote plugins use these hosts.
  withNodeJs = false;
  withPerl = false;
  withPython3 = false;
  withRuby = false;
  # Linux hosts are servers; the clipboard there is OSC 52 (options.nix).
  waylandSupport = false;

  # vim.loader caches compiled Lua modules and resolves them without a
  # runtimepath scan. It goes first, so every require in init uses it;
  # luaLoader.enable emits the same call after lz.n and the globals.
  extraConfigLuaPre = lib.mkOrder 0 "vim.loader.enable()";
  # byteCompileLua compiles the generated init, plugin configs, plugins and
  # Neovim's own Lua at build time.
  performance.byteCompileLua = {
    enable = true;
    initLua = true;
    configs = true;
    plugins = true;
    nvimRuntime = true;
  };
  # One runtimepath entry for the start plugins makes every runtime file
  # lookup cheaper. Plugins with files that collide with another plugin's
  # stay separate: snacks (treesitter queries) and oil (doc/recipes.md).
  performance.combinePlugins = {
    enable = true;
    standalonePlugins = [
      config.plugins.snacks.package
      config.plugins.oil.package
    ];
  };

  # Every program the config calls comes from the tool environments here and
  # in languages.nix, appended to PATH, so a project's direnv shell wins.
  # One environment is one PATH entry: each entry costs the shell wrapper a
  # pattern match at every start.
  autowrapRuntimeDeps = false;
  dependencies.fzf.enable = false;
  extraPackagesAfter = [
    (pkgs.buildEnv {
      name = "nvim-cli-tools";
      paths = with pkgs; [
        git
        gh
        ripgrep
        fd
        fzf
      ];
    })
  ];
}
