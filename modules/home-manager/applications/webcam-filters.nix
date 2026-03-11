{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    webcam-filters
  ];
}
