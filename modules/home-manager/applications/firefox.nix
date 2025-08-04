# ./modules/home-manager/applications/firefox.nix (using NUR)
{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "browser.startup.page" = 3;
        "browser.startup.homepage" = "https://nixos.org";
      };

      extensions = {
        # This is now much cleaner!
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          violentmonkey
        ];
      };
    };
  };
}