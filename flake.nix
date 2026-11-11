{
  description = "Neovim with this config, its plugins and its language tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mnw.url = "github:Gerg-L/mnw";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      mnw,
      neovim-nightly-overlay,
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
      packages = eachSystem (pkgs: {
        default = mnw.lib.wrap {
          inherit pkgs;
          neovim-nightly = neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
        } ./config.nix;
      });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.lua-language-server
            pkgs.stylua
            pkgs.nixfmt
          ];
        };
      });

      formatter = eachSystem (pkgs: pkgs.nixfmt-tree);
    };
}
