{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        enkia.tokyo-night
        Google.gemini-cli-vscode-ide-companion
      ];
      
      userSettings = {
        "workbench.colorTheme" = "Tokyo Night";        
        "gemini.enable" = true;
      };
    };
  };
}
