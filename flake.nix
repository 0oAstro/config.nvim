{
  description = "Neovim nightly configured in Nix with nixvim: plugins, options, keys, languages and tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flexoki-neovim = {
      url = "github:kepano/flexoki-neovim";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixvim,
      neovim-nightly-overlay,
      flexoki-neovim,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      # The nixvim configuration evaluated against a given package set, so a
      # consumer's overlays and pins apply.
      lib.evalNeovim =
        pkgs:
        nixvim.lib.evalNixvim {
          modules = [
            { nixpkgs.pkgs = pkgs; }
            ./modules
          ];
          extraSpecialArgs = {
            neovim-nightly = neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
            inherit flexoki-neovim;
          };
        };

      lib.mkNeovim = pkgs: (self.lib.evalNeovim pkgs).config.build.package;

      packages = eachSystem (pkgs: {
        default = self.lib.mkNeovim pkgs;
      });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.hyperfine
            pkgs.nixfmt
          ];
        };
      });

      formatter = eachSystem (pkgs: pkgs.nixfmt-tree);
    };
}
