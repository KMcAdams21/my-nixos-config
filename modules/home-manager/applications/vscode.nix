{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        enkia.tokyo-night
        anthropic.claude-code
        Google.gemini-cli-vscode-ide-companion
      ];
      
      userSettings = {
        "workbench.colorTheme" = "Tokyo Night";        
        "claude.autoSave" = true;
        "gemini.enable" = true;
      };
    };
  };
}