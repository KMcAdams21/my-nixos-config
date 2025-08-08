{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.google-chrome
  ];
}