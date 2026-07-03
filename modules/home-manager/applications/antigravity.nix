{ config, pkgs, ... }:

{
  home.packages = [
    # This automatically includes the FHS environment and Chrome wrappers
    pkgs.antigravity
  ];

  xdg.configFile."antigravity/settings.json".text = builtins.toJSON {
    "workbench.colorTheme" = "Tokyo Night";
    "editor.fontFamily" = "JetBrains Mono";
    "agent.auto_approve_commands" = false;
    # These match the settings you were using in VS Code
    "gemini.enable" = true; 
  };
}