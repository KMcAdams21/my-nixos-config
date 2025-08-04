{ config, pkgs, inputs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  programs.spicetify = {
    # This is essential for Spicetify-Nix to patch the correct Spotify client.
    spotifyPackage = pkgs.spotify;

    enable = true;

    autoUpdate = true;

    # Set the theme to "Sleek Future".
    theme = spicePkgs.themes.sleekFuture;

    # Set the color scheme for the theme
    colorScheme = "main";

    # Enable extensions.
    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      shufflePlus
      hidePodcasts
      lyricsPlus
    ];

    # Enable custom apps that provide additional features.
    enabledCustomApps = with spicePkgs.apps; [
      newReleases
    ];
  };
}
