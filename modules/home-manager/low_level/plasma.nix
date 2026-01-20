{ config, pkgs, ... }:
{
  programs.plasma = {
    enable = true;
    
    workspace = {
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "Tela-dark";
      cursor.theme = "Vimix-cursors";
    };

    # Custom keyboard shortcuts
    hotkeys.commands = {
      "Toggle HDR" = {
        name = "Toggle HDR";
        comment = "Toggle HDR and Wide Color Gamut on Innocn monitor";
        key = "Meta+H";
        command = "/home/km/nixos-config/scripts/toggle-hdr.sh";
      };
    };
  };
}
