{ config, pkgs, ... }:

{
  # whisper-dictation itself is installed system-wide (environment.systemPackages)
  # with its deps bundled (whisper-cpp, ffmpeg, ydotool, libnotify). This module
  # only auto-starts its daemon via systemd user unit.

  # Auto-start the whisper-dictation daemon on graphical login so the
  # push-to-talk hotkey (Super+Period by default) is always live.
  # Needs the ydotool group (programs.ydotool) + input group for evdev.
  systemd.user.services.whisper-dictation = {
    Unit = {
      Description = "Whisper Dictation - local speech-to-text daemon";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "/run/current-system/sw/bin/whisper-dictation";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = "PYTHONUNBUFFERED=1";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}