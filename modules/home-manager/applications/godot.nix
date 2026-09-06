{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    godot
    godot_4-export-templates-bin
    godot-mcp
  ];
}