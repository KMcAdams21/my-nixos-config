{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    openai-whisper
    ffmpeg
    wtype
    libnotify
  ];
}