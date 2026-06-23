{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (retroarch.withCores (cores: with cores; [
        # Nintendo DS
        desmume
        melonds

        # Game Boy / GBA
        mgba
        gambatte

        # NES / SNES
        fceumm
        snes9x

        # N64
        mupen64plus

        # PlayStation
        pcsx-rearmed
        beetle-psx-hw

        # Sega
        genesis-plus-gx
        picodrive

        # Arcade
        mame
        fbneo
      ]))

  ];
}
