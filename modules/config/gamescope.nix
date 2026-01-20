{ config, pkgs, ... }:

{
  # Enable gamescope - Valve's micro-compositor for gaming with HDR support
  programs.gamescope = {
    enable = true;
    
    # Enable cap_sys_nice capability for better performance scheduling
    capSysNice = true;
  };

  # Add gamescope packages to system
  environment.systemPackages = with pkgs; [
    gamescope
  ];
}
