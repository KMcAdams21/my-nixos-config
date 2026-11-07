# ./modules/home-manager/applications/vesktop.nix
{ config, pkgs, ... }:

{
  programs.vesktop = {
    enable = true;

    # Keep in-app changes; declarative values below take precedence on rebuild.
    mutableSettings = true;

    settings = {
      tray = true;
      minimizeToTray = true;
      disableSmoothScroll = true;
      hardwareAcceleration = true;
    };
  };
}
