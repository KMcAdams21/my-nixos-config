{ config, pkgs, ... }:

{
  programs.steam = {
    enable = true;

    # Enable all optional firewall ports for Steam features
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    # Enable Gamescope for a better gaming experience
    gamescopeSession.enable = true;

    # Include proton compatibility packages
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
}
