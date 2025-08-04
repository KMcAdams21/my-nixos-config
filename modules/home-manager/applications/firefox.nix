{ config, pkgs, firefox-addons, ... }:

let
  # Now we can use firefox-addons directly from the arguments
  violentmonkey-addon = firefox-addons.buildAddon {
    pname = "violentmonkey";
    version = "2.31.0";
    url = "https://addons.mozilla.org/firefox/downloads/file/4455138/violentmonkey-2.31.0.xpi";
    sha256 = "1fld40j9zcdjbhz2h410k38c8s8pfd70s0q616335g9s16y06qj";
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
