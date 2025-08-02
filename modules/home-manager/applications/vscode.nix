{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        enkia.tokyo-night
      ];
      userSettings = {
        "workbench.colorTheme" = "Tokyo Night";
      };
    };
  };
}
