# mullvad.nix

{ pkgs, ... }:

{
  # Mullvad VPN Configuration
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  services.resolved.enable = true;
}