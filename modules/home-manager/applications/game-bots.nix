{ config, pkgs, ... }:

let
  # pynput comes straight from nixpkgs — no pip needed
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.pynput ]);

  botSrc = "${config.home.homeDirectory}/nixos-config/scripts/game-bots";

  # Wraps runner.py as a `game-bot` command on PATH
  gameBotPkg = pkgs.writeShellApplication {
    name = "game-bot";
    runtimeInputs = [ pythonEnv ];
    text = ''exec python3 "${botSrc}/runner.py" "$@"'';
  };

in
{
  home.packages = [ gameBotPkg ];
}
