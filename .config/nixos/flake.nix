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
    inputs@{
      nixpkgs,
      home-manager,
      vscode-extensions,
      ...
    }:
    {
      nixosConfigurations = {
        "DESKTOP-I09770C" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
            ./machines/DESKTOP-I09770C.nix

            { nixpkgs.overlays = [ vscode-extensions.overlays.default ]; }

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users = {
                  reznak = import ./home.nix;
                };
              };
            }
          ];
        };
        "probook-455-g8" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
            ./machines/probook-455-g8.nix

            { nixpkgs.overlays = [ vscode-extensions.overlays.default ]; }

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users = {
                  reznak = import ./home.nix;
                };
              };
            }
          ];
        };
      };
    };
}
