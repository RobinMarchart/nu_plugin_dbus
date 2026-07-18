# modified from nixpkgs, use updated fork

{
  stdenv,
  lib,
  rustPlatform,
  pkg-config,
  nix-update-script,
  dbus,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nu_plugin_dbus";
  version = "0.14.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./Cargo.lock
      ./Cargo.toml
      ./src
    ];
  };
  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [ pkg-config ] ++ lib.optionals stdenv.cc.isClang [ rustPlatform.bindgenHook ];
  buildInputs = [ dbus ];

  passthru.updateScript = nix-update-script { };

  __structuredAttrs = true;
  meta = {
    description = "Nushell plugin for communicating with D-Bus";
    mainProgram = "nu_plugin_dbus";
    homepage = "https://github.com/devyn/nu_plugin_dbus";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aftix ];
    platforms = lib.platforms.linux;
  };
})
