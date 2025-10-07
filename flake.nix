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

  outputs = { self, nixpkgs, home-manager, nur, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      devShell = import ./modules/shells/devshell.nix { inherit pkgs; };
      
    in
    {
      devShells.${system}.default = devShell;

      nixosConfigurations.my-basic-nixos = nixpkgs.lib.nixosSystem {
        inherit system; # Using inherit for 'system'

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