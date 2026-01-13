# ./modules/home-manager/applications/firefox.nix
{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "browser.startup.page" = 3;
        "browser.startup.homepage" = "https://nixos.org";

        # Enable native vertical tabs.
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
      };

      extensions = {
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          violentmonkey
          onepassword-password-manager
          tabwrangler
        ];
      };
    };
  };
}