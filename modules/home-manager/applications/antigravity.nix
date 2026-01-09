{ config, pkgs, antigravity-nix, ... }:

{
  home.packages = [
    # This automatically includes the FHS environment and Chrome wrappers
    antigravity-nix.packages.${pkgs.system}.default
  ];

  xdg.configFile."antigravity/settings.json".text = builtins.toJSON {
    "workbench.colorTheme" = "Tokyo Night";
    "editor.fontFamily" = "JetBrains Mono";
    "agent.auto_approve_commands" = false;
    # These match the settings you were using in VS Code
    "gemini.enable" = true; 
  };
}