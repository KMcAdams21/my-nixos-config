{ config, pkgs, ... }:

{
  programs.discord = {
    enable = true;

    # Optionally, you can add flags or settings here.
    # For example, to run Discord in a specific way:
    # commandLineArgs = [ "--some-flag" ];
  };
}
