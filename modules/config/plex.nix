# plex.nix

{ pkgs, ... }:

{
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  # Plex runs as its own `plex` system user, but /home/km is mode 700.
  # Bind-mount the Plex folder at a path the service can read.
  fileSystems."/Plex" = {
    device = "/home/km/Plex";
    options = [ "bind" ];
  };
}