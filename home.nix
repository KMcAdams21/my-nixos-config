{ config, pkgs, ... }:

{
  home.username = "km";
  home.homeDirectory = "/home/km";
  home.stateVersion = "25.11"; # Make sure this matches your NixOS version

  programs.git = {
    enable = true;
    userName = "Kendrick";
    userEmail = "mcadams.kendrick@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  # Enable the SSH client and agent for your user through Home Manager
  programs.ssh.enable = true;

  # You can also add more specific SSH client settings here if needed
  # programs.ssh.knownHosts = [
  #   {
  #     host = "github.com";
  #     key = "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkhtFVeeRIuY/s/gXyZYyaDweq6xxFtk2NzmhwM";
  #   }
  # ];
}
