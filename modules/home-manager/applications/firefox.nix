# /etc/nixos/modules/firefox.nix
{ config, pkgs, ... }:

{
  programs.firefox.enable = true;
  programs.firefox.profiles.default = {
    settings = {
      "browser.startup.page" = 3;
      "browser.startup.homepage" = "https://nixos.org";
    };
  };
}