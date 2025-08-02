{
	description = "My Basic NixOS Config";
	
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = { self, nixpkgs, home-manager, ... }: {
		nixosConfigurations.my-basic-nixos = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				{ nixpkgs.config.allowUnfree = true;  }
				./configuration.nix
				home-manager.nixosModules.home-manager
				{
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
					home-manager.users.km = import ./home.nix;
				}
			];
		};
	};
}
