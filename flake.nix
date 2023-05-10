{
  description = "a discord bot for playing the coup card game written in elixir";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      defaultBuildInputs = [ pkgs.elixir ];
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = defaultBuildInputs;
        shellHook=''
        export MIX_ARCHIVE=/konst/home/.mix-archive
        '';
      };
    };
}
