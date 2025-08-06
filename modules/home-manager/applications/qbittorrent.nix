/*
  qBittorrent + Mullvad-only tunnel for NixOS
*/
{ config, pkgs, lib, ... }:

let
  qbUser = "qbittorrent";
  qbGroup = "qbittorrent";
in
{
  # Create a dedicated system user for qBittorrent
  users.users.
    qbUser = {
      isSystemUser = true;
      description = "qBittorrent download user";
      home = "/var/lib/qbittorrent";
      createHome = true;
      group = qbGroup;
    };

  # Install the qBittorrent-nox daemon
  services.qbittorrent.enable = true;
  services.qbittorrent.user = qbUser;
  services.qbittorrent.group = qbGroup;
  services.qbittorrent.profile = "/var/lib/qbittorrent";
  services.qbittorrent.webUI = {
    enable = true;
    port = 8080;
  };

  # Restrict qBittorrent traffic to the wg-mullvad interface only
  networking.firewall = {
    # Keep existing rules from mullvad-kill-switch
    extraCommands = lib.concatStringsSep "\n" [
      # Allow qBittorrent user egress only via wg-mullvad
      "nft add rule inet filter output oifname \"wg-mullvad\" owner uid $(id -u qbittorrent) accept"
      "nft add rule inet filter output owner uid $(id -u qbittorrent) drop"
    ];
  };

  # Ensure qBittorrent daemon starts after the VPN is up
  systemd.services."qbittorrent-nox" = {
    after = [ "wg-quick@wg-mullvad.service" ];
    wants = [ "wg-quick@wg-mullvad.service" ];
  };

  # Add qBittorrent to system packages (optional CLI)
  environment.systemPackages = with pkgs; [ qbittorrent-nox ];
}
