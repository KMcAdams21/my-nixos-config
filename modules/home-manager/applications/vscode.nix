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
        "editor.quickSuggestions" = {
          other = false;
          comments = false;
          strings = false;
        };
        "editor.acceptSuggestionOnCommitCharacter" = false;
        "editor.acceptSuggestionOnEnter" = "off";
        "editor.suggestOnTriggerCharacters" = false;
        "editor.wordBasedSuggestions" = "off";
      };
    };
  };
}
