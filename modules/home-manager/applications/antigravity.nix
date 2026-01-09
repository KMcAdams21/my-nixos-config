{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.antigravity-fhs
  ];

  xdg.configFile."antigravity/settings.json".text = builtins.toJSON {
    "appearance.theme" = "tokyo-night";
    "agent.auto_approve_commands" = false;
    "agent.model" = "gemini-3-flash";
    "telemetry.enabled" = false;
    "editor.fontFamily" = "JetBrains Mono";
  };

  xdg.configFile."antigravity/keybindings.json".text = builtins.toJSON [
    {
      "command" = "agent.summon";
      "key" = "ctrl+space";
    }
  ];
}