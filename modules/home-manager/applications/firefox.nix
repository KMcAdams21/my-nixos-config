{ config, pkgs, ... }:

let
  firefox-addons = pkgs.firefox-addons;
  violentmonkey-addon = pkgs.firefox-addons.buildAddon {
    pname = "violentmonkey";
    version = "2.31.0";
    url = "https://addons.mozilla.org/firefox/downloads/file/4455138/violentmonkey-2.31.0.xpi";
    sha256 = "sha256-J/SjW6eLq4lM4qPzD4lV8kQyD5lV7oK8xK4nS1lW4oK="; # Replace with the actual sha256
    meta = with pkgs.lib; {
      description = "Userscript support for browsers";
      homepage = "https://violentmonkey.github.io/";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };

in
{
  programs.firefox.enable = true;
  programs.firefox.profiles.default = {
    settings = {
      "browser.startup.page" = 3;
      "browser.startup.homepage" = "https://nixos.org";
    };
    extensions.packages = [
      violentmonkey-addon
    ];
  };
}