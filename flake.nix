# flake.nix
{
  description = "My Basic NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, nur, ... }: {
    nixosConfigurations.my-basic-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({
          nixpkgs.overlays = [ nur.overlays.default ];
        })
		    { nixpkgs.config.allowUnfree = true; }
        
		    ./configuration.nix
    
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.km = import ./home.nix;
        }

        ./modules/config/mullvad.nix
      ];
    };
  };
}
