{ config, pkgs, ... }:

{
  programs.plasma = {
    enable = true;
    
    workspace = {
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      lookAndFeel = "org.kde.breezedark.desktop";
    };
  };
}
