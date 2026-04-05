{ config, pkgs, ... }:

let
  # All Python deps come from nixpkgs — no pip needed
  pythonEnv = pkgs.python3.withPackages (ps: [
    ps.pynput   # keyboard simulation (used by both CLI and tray)
    ps.pyqt6    # system tray GUI
  ]);

  botSrc = "${config.home.homeDirectory}/nixos-config/scripts/game-bots";

  # CLI runner: `game-bot movement_farmer [--sneak]`
  gameBotCli = pkgs.writeShellApplication {
    name = "game-bot";
    runtimeInputs = [ pythonEnv ];
    text = ''exec python3 "${botSrc}/runner.py" "$@"'';
  };

  # Tray app: `game-bot-tray`  (add to autostart below)
  gameBotTray = pkgs.writeShellApplication {
    name = "game-bot-tray";
    runtimeInputs = [ pythonEnv ];
    text = ''exec python3 "${botSrc}/tray.py" "$@"'';
  };

in
{
  home.packages = [ gameBotCli gameBotTray ];

  # Auto-start the tray app when you log in
  xdg.configFile."autostart/game-bot-tray.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Game Bot Tray
    Exec=${gameBotTray}/bin/game-bot-tray
    Icon=input-gaming
    Comment=Game bot runner system tray
    Categories=Game;
    StartupNotify=false
    X-KDE-autostart-phase=2
  '';
}
