{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    foundry = {
      url = "github:shazow/foundry.nix/monthly"; # Use monthly branch for permanent releases
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };
    solc = {
      url = "github:hellwolf/solc.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };
  };

  outputs = { self, nixpkgs, utils, foundry, solc }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ foundry.overlay solc.overlay ];
        };
      in
      {
        devShells.default = pkgs.mkShell
          {
            packages = with pkgs; [
              foundry-bin
              solc_0_8_26
              (solc.mkDefault pkgs solc_0_8_26)
            ];

            shellHook = ''
              forge install
            '';
          };
      });
}
