{ config, pkgs, ... }:

{
  systemd.user.services.audio-switch = {
    Unit = {
      Description = "Automatic Audio Switcher for Headset";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      # Points to the script we created. 
      # Using the absolute path ensures it works even if PATH is minimal, 
      # though we rely on headsetcontrol/wpctl being in the system PATH available to the user service.
      ExecStart = "${config.home.homeDirectory}/nixos-config/scripts/auto-switch-audio.sh";
      
      # Run the script, wait 2 seconds, then run again (looping behavior)
      Restart = "always";
      RestartSec = 2;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
