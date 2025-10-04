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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      vscode-extensions,
      sops-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      sharedModules = [
        ./configuration.nix
        ./hardware-configuration.nix
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        { nixpkgs.overlays = [ vscode-extensions.overlays.default ]; }
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
          };
        }
      ];
    in
    {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            reznak = import ./users/reznak.nix;
          };

          modules = sharedModules ++ [
            ./machines/desktop.nix
            ./specialisations/reznak.nix
          ];
        };

        laptop = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            reznak = import ./users/reznak.nix;
            reznaksr = import ./users/reznaksr.nix;
            isSpecialisation = true;
          };

          modules = sharedModules ++ [
            ./machines/laptop.nix
            {
              specialisation = {
                reznak.configuration = import ./specialisations/reznak.nix;
                reznaksr.configuration = import ./specialisations/reznaksr.nix;
              };
            }
          ];
        };
      };
    };
}
