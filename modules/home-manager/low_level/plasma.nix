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
  };
}
