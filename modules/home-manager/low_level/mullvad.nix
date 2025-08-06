/*
  Mullvad VPN configuration for NixOS (WireGuard + Toggleable Kill Switch)
*/
{ config, pkgs, lib, ... }:

let
  privateKeyFile = "/var/lib/mullvad/wg_private.key";
  wgAddress = "10.66.66.2/32";
  wgEndpoint = "sea-wireguard.mullvad.net:51820";
in
{
  networking.wireguard.interfaces.mullvad = {
    address = [ wgAddress ];
    privateKeyFile = privateKeyFile;
    listenPort = 51820;
    peers = [ {
      publicKey = "<MULLVAD_PUBLIC_KEY>";
      allowedIPs = [ "0.0.0.0/0" "::/0" ];
      endpoint = wgEndpoint;
      persistentKeepalive = 25;
    } ];
  };

  # Separate kill-switch service that can be started/stopped independently
  systemd.services.mullvad-kill-switch = {
    description = "Mullvad VPN kill switch (nftables)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      # Flush existing rules
      nft flush ruleset

      # Create filter table
      nft add table inet filter

      # Input chain: allow loopback and established
      nft add chain inet filter input { type filter hook input priority 0; }
      nft add rule inet filter input iifname lo accept
      nft add rule inet filter input ct state established,related accept
      nft add rule inet filter input udp dport 51820 accept

      # Output chain: drop all unless going out via wg interface
      nft add chain inet filter output { type filter hook output priority 0; }
      nft add rule inet filter output oifname "wg-mullvad" accept
      nft add rule inet filter output drop
    '';
    wantedBy = [ "multi-user.target" ];
  };

  # Ensure WireGuard service and kill-switch start at boot (enable as needed)
  systemd.services."wg-quick@wg-mullvad".wantedBy = [ "multi-user.target" ];
  # Enable kill-switch by default; stop it when VPN is not wanted
  systemd.services."mullvad-kill-switch".enable = true;

  # Ensure the private key exists with correct perms
  environment.etc."var/lib/mullvad/wg_private.key" = {
    source = privateKeyFile;
    mode = "0400";
  };
}
