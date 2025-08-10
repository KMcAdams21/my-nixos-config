/*
  Mullvad VPN configuration for NixOS (WireGuard + Kill Switch)
*/
{ config, pkgs, lib, ... }:

let
  # The path to the private key file
  privateKeyFile = "/var/lib/mullvad/wg_private.key";
  # The IP address assigned to your WireGuard interface
  wgAddress = "10.66.66.2/32";
  # Mullvad's public key for the server
  mullvadPublicKey = "<MULLVAD_PUBLIC_KEY>";
  # Mullvad's WireGuard endpoint
  wgEndpoint = "sea-wireguard.mullvad.net:51820";
in
{
  # WireGuard configuration
  networking.wireguard.interfaces.mullvad = {
    # The IP addresses for the WireGuard interface.
    addresses = [ wgAddress ];
    # Path to the private key.
    privateKeyFile = privateKeyFile;
    # WireGuard's listening port.
    listenPort = 51820;
    peers = [
      {
        # Mullvad's public key for the server.
        publicKey = mullvadPublicKey;
        # Routes all traffic through the VPN.
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        # The Mullvad WireGuard server endpoint.
        endpoint = wgEndpoint;
        # Keeps the connection alive by sending a packet every 25 seconds.
        persistentKeepalive = 25;
      }
    ];
    # Post-up and Post-down scripts for the kill switch.
    # These rules are tightly coupled to the WireGuard interface's lifecycle.
    postUp = ''
      # Flush existing rules to start fresh
      nft flush ruleset
      # Create a filter table
      nft add table inet filter
      # Add input chain with a drop policy by default
      nft add chain inet filter input { type filter hook input priority 0; policy drop; }
      # Add output chain with a drop policy by default
      nft add chain inet filter output { type filter hook output priority 0; policy drop; }
      # Input rules
      nft add rule inet filter input iifname lo accept
      nft add rule inet filter input ct state established,related accept
      nft add rule inet filter input iifname "mullvad" accept
      # Output rules
      nft add rule inet filter output oifname lo accept
      nft add rule inet filter output ct state established,related accept
      nft add rule inet filter output oifname "mullvad" accept
    '';
    postDown = ''
      # Flush all rules when the VPN goes down
      nft flush ruleset
    '';
  };

  # Enable the WireGuard service.
  networking.wireguard.enable = true;

  # Ensure the private key exists with correct permissions.
  environment.etc."mullvad-private.key" = {
    text = "<YOUR_PRIVATE_KEY>";
    mode = "0400";
  };
}