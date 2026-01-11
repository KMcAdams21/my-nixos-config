{ config, pkgs, ... }:

{
  # Prevent AUTOMATIC sleep/suspend/hibernate from idle timeout
  # Manual sleep (via menu, command, or closing lid) will still work

  services.logind = {
    extraConfig = ''
      IdleAction=ignore
      IdleActionSec=0
    '';
  };

  # Disable automatic suspend via power profiles daemon
  services.power-profiles-daemon.enable = false;
}
