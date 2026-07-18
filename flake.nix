{
  description = "nu_plugin_dbus";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs =
    {
      nixpkgs,
      systems,
      ...
    }:
    let
      lib = nixpkgs.lib;
      eachSystem =
        f:
        let
          forSystem = system: builtins.mapAttrs (name: val: { ${system} = val; }) (f system);
          sets = map forSystem (import systems);
        in
        builtins.foldl' lib.attrsets.recursiveUpdate { } sets;
    in
    (eachSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        nushell-plugin-dbus = pkgs.callPackage (import ./dbus-plugin.nix) { };
      in
      {
        formatter = pkgs.nixfmt-tree;
        packages = { inherit nushell-plugin-dbus; };
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nushell
            pkgs.dbus
          ];
          nativeBuildInputs = [
            pkgs.pkg-config
            pkgs.rustc
            pkgs.cargo
            pkgs.clippy
            pkgs.rust-analyzer
          ];
        };
      }
    ))
    // (
      let
        nushell-plugin-dbus = final: prev: {
          nushell-plugin-dbus = final.callPackage ./dbus-plugin.nix { };
        };
      in
      {
        overlays = {
          inherit nushell-plugin-dbus;
          default = nushell-plugin-dbus;
        };
      }
    );
}
