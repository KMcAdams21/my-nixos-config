{
  description = "My Basic NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, nur, antigravity-nix, plasma-manager, ... }: {
    nixosConfigurations.my-basic-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ nixpkgs.overlays = [ nur.overlays.default ]; })
        { nixpkgs.config.allowUnfree = true; }
        
        ./configuration.nix
        ./modules/config/mullvad.nix

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.km = import ./home.nix;
          home-manager.extraSpecialArgs = { inherit antigravity-nix; };
          home-manager.sharedModules = [
            plasma-manager.homeModules.plasma-manager
          ];
        }
      ];
    };
  };
}