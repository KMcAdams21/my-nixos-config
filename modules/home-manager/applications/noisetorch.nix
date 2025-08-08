{ config, pkgs, lib, ... }:

let
  nt = pkgs.noisetorch;
in
{
  environment.systemPackages = [ nt ];

  # Auto-start service
  systemd.user.services.noisetorch = {
    description = "NoiseTorch: RNNoise-based noise suppression";
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = lib.mkForce "${nt}/bin/noisetorch --noise-suppression rnnoise --mic default";
      Restart = "on-failure";
      RestartSec = 5;
    };
    wantedBy = [ "default.target" ];
  };

  # KDE Plasma autostart
  services.xserver.displayManager.sessionCommands = ''
    # Ensure NoiseTorch starts after login
    ${nt}/bin/noisetorch --noise-suppression rnnoise --mic default &
  '';

  # Defaults & overrides
  # Force PipeWire to see the NoiseTorch virtual source
  environment.etc."pipewire/media-session.d/99-noisetorch-virtual-setup.conf".text = ''
    context.exec = [
      "${nt}/bin/noisetorch --noise-suppression rnnoise --mic default"
    ];
  '';

  programs.plasma5 = {
    enable = true;
  };
}
