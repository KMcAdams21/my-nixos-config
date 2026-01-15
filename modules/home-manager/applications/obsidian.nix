{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    obsidian
  ];

  # Future extension configuration can be added here
  # For example, you could symlink plugins/themes from your dotfiles
  # home.file.".config/obsidian/..." = { ... };
}
