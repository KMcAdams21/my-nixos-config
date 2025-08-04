# flake.nix
{
  description = "My Basic NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, firefox-addons, ... }: {
    nixosConfigurations.my-basic-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
		{ nixpkgs.config.allowUnfree = true; }
        
		./configuration.nix
    
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.km = {
            imports = [ ./home.nix ];
            _module.args = {
              inherit (firefox-addons) firefox-addons;
            };
          };
        }
      ];
    };
  };
}
