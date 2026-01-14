{ config, pkgs, ... }:

{
  systemd.user.services.noisetorch = {
    Unit = {
      Description = "NoiseTorch Noise Suppression";
      After = [ "pipewire.service" "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      # -i specifies input device, -s sets it as default source
      ExecStart = "${pkgs.noisetorch}/bin/noisetorch -i alsa_input.usb-HP__Inc_HyperX_QuadCast_S-00.analog-stereo -s";
      # Unload NoiseTorch on stop
      ExecStop = "${pkgs.noisetorch}/bin/noisetorch -u";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
