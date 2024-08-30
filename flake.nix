{
  description = "LaTeX flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # autotex.url = "github:e0328eric/autotex";
    # autotex.flake = false;
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      lib = nixpkgs.lib;
      systems = lib.systems.flakeExposed;
      pkgsFor = lib.genAttrs systems (system: import nixpkgs { inherit system; });
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
    in
    {
      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            nixd
            nixfmt-rfc-style
            # TODO: only specify used packages, as described in https://nixos.wiki/wiki/TexLive
            texlive.combined.scheme-full
            texlab
            pandoc
            zathura
            sioyek
            (python311.withPackages (ps: with ps; [ pygments ]))
            # (rustPlatform.buildRustPackage {
            #   pname = "autotex";
            #   version = "master";
            #   src = inputs.autotex;
            #   cargoHash = "sha256-AlKYlNALAW0R6vlGlNlUQUkKvcxYJ+8WCMhU6weLEWc=";
            # })
            (writeShellScriptBin "latex-compile" ''latexmk -pdf -lualatex -lualatex="lualatex %O --shell-escape %S" -pvc'')
          ];
        };
      });
      # TODO: maybe provide compiled documents as derivations?
    };
}
