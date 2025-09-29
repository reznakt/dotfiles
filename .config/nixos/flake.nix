{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      vscode-extensions,
      ...
    }:
    let
      mkSystem =
        machineModule:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix

            machineModule

            { nixpkgs.overlays = [ vscode-extensions.overlays.default ]; }

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users = {
                  reznak = import ./users/reznak.nix;
                  reznaksr = import ./users/reznaksr.nix;
                };
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        desktop = mkSystem ./machines/desktop.nix;
        laptop = mkSystem ./machines/laptop.nix;
      };
    };
}
