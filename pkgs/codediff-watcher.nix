{
  lib,
  rustPlatform,
  src,
}:
rustPlatform.buildRustPackage {
  pname = "codediff-watcher";
  version = "0.23.2";
  inherit src;
  cargoHash = "sha256-wiyDnyYop2lbmUVt5H4SiizaE4Kl5pAkBn5r8c3M9UI=";
  cargoBuildFlags = [
    "-p"
    "watcher"
    "--bin"
    "codediff-watcher"
  ];
  doCheck = false;
  meta = {
    description = "Git repository watcher for CodeDiff";
    homepage = "https://github.com/esmuellert/codediff";
    license = lib.licenses.mit;
    mainProgram = "codediff-watcher";
  };
}
