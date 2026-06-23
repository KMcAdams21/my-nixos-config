{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    melonDS
  ];
}
