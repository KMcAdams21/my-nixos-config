{ config, pkgs, ... }:

{
  home.username = "km";
  home.homeDirectory = "/home/km";
  home.stateVersion = "25.11"; # Make sure this matches your NixOS version

  home.packages = with pkgs; [
    spotify
    discord
    pkgs.qbittorrent
    dnsutils  # provides dig and nslookup
  ];

  # Import individual Home Manager modules for specific applications/services
  imports = [
    # Applications
    ./modules/home-manager/applications/git.nix
    ./modules/home-manager/applications/vscode.nix
    ./modules/home-manager/applications/firefox.nix
    ./modules/home-manager/applications/dolphin.nix
    ./modules/home-manager/applications/googleChrome.nix
    ./modules/home-manager/applications/antigravity.nix
    ./modules/home-manager/applications/onepassword.nix
    ./modules/home-manager/applications/prusaslicer.nix
    ./modules/home-manager/applications/obsidian.nix
    ./modules/home-manager/applications/blender.nix
    ./modules/home-manager/applications/youtube-music.nix

    # Shell Configuration
    ./modules/home-manager/low_level/bash.nix
    ./modules/home-manager/low_level/readline.nix

    # Services
    ./modules/home-manager/low_level/ssh.nix

    # Theme Configuration
    ./modules/home-manager/low_level/plasma.nix
    ./modules/home-manager/low_level/theme.nix
    
    # Custom Modules
    ./modules/home-manager/audio-switch.nix
    ./modules/home-manager/noisetorch.nix
  ];
}
