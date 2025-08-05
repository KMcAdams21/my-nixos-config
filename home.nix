{ config, pkgs, ... }:

{
  home.username = "km";
  home.homeDirectory = "/home/km";
  home.stateVersion = "25.11"; # Make sure this matches your NixOS version

  home.packages = with pkgs; [
    discord
  ];

  # Import individual Home Manager modules for specific applications/services
  imports = [
    # Applications
    ./modules/home-manager/applications/git.nix
    ./modules/home-manager/applications/vscode.nix
    ./modules/home-manager/applications/firefox.nix
    ./modules/home-manager/applications/spotify.nix

    # Shell Configuration
    ./modules/home-manager/low_level/bash.nix
    ./modules/home-manager/low_level/readline.nix

    # Services
    ./modules/home-manager/low_level/ssh.nix
  ];
}
