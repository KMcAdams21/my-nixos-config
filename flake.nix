{
  description = "My Basic NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    whisper-dictation = {
      url = "github:jacopone/whisper-dictation";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, nur, antigravity-nix, plasma-manager, whisper-dictation, ... }: {
    nixosConfigurations.my-basic-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ nixpkgs.overlays = [
          nur.overlays.default
          antigravity-nix.overlays.default
          (final: prev: {
            antigravity = final.google-antigravity;
          })
          (final: prev: {
            whisper-dictation = whisper-dictation.packages.${prev.system}.default;
          })
        ]; })
        { nixpkgs.config.allowUnfree = true; }
        
        ./configuration.nix
        ./modules/config/mullvad.nix

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.km = import ./home.nix;
          home-manager.sharedModules = [
            plasma-manager.homeModules.plasma-manager
          ];
        }
      ];
    };
  };
}