{ config, pkgs, ... }:

{
  # Enable Gamescope compositor with elevated privileges for better performance
  programs.gamescope = {
    enable = true;
    capSysNice = true;  # Allows better scheduling priority for games
  };

  programs.steam = {
    enable = true;

    # Enable all optional firewall ports for Steam features
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    # Enable Gamescope session (Steam Deck-like experience)
    gamescopeSession.enable = true;

    # Include proton compatibility packages
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  # Required for HDR support in Gamescope
  environment.systemPackages = with pkgs; [
    gamescope-wsi
  ];
}
