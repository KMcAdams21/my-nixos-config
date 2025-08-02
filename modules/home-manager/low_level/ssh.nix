{ config, pkgs, ... }:

{
  programs.ssh.enable = true;

  # You can uncomment and add specific SSH client settings here if needed
  # programs.ssh.knownHosts = [
  #  {
  #    host = "github.com";
  #    key = "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkhtFVeeRIuY/s/gXyZYyaDweq6xxFtk2NzmhwM";
  #  }
  # ];
}
