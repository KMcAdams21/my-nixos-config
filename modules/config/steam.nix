{ config, pkgs, ... }:

{

  programs.steam = {
    enable = true;

    # Enable all optional firewall ports for Steam features
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    # Include proton compatibility packages
    extraCompatPackages = [ pkgs.proton-ge-bin ];

    # Enable Steam + Gamescope session for HDR and better performance
    gamescopeSession = {
      enable = true;
    };
  };
}
