{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.dolphin-emu
  ];

  xdg.configFile."dolphin-emu/Dolphin.ini".text = ''
    [Core]
    DSPHLE = True
    HLE_BS2 = True
    Fastmem = True
    CPUThread = True

    [Display]
    Fullscreen = False
    KeepWindowOnTop = False
    RenderToMain = True

    [Dolphin]
    ShowLag = False
    ShowFPS = False
    ShowSpeed = False
    ShowNetLatency = False
    ShowPI = False
    ShowMem = False
    ShowFrameCount = False
    GFXBackend = Vulkan
    InternalResolution = 3
    MaxAnisotropy = 16
    AntiAliasing = 4

    [Hotkeys]
    SaveStateSlot1 = Shift+F1
    LoadStateSlot1 = F1
    ToggleFullscreen = Alt+Return
    TogglePause = Space
  '';

  xdg.configFile."dolphin-emu/Config/GCPadNew.ini".text = ''
    [Profile]
    Device = SDL/0/PLAYSTATION(R)4 Controller
    
    # D-Pad
    D-Pad/Up = `Pad N`
    D-Pad/Down = `Pad S`
    D-Pad/Left = `Pad W`
    D-Pad/Right = `Pad E`
    
    # Face Buttons
    Buttons/A = `Button B` # Cross on PS4
    Buttons/B = `Button A` # Circle on PS4
    Buttons/X = `Button Y` # Triangle on PS4
    Buttons/Y = `Button X` # Square on PS4
    Buttons/Z = `Shoulder R` # R1 on PS4
    Buttons/Start = Start # Options/Start button on PS4

    # Main Stick (Left Analog Stick on PS4)
    Main Stick/Radius = 60.000000000000000
    Main Stick/Dead Zone = 12.000000000000000
    Main Stick/Up = `Left Y+`
    Main Stick/Down = `Left Y-`
    Main Stick/Left = `Left X-`
    Main Stick/Right = `Left X+`

    # C-Stick (Right Analog Stick on PS4)
    C-Stick/Radius = 65.000000000000000
    C-Stick/Dead Zone = 17.000000000000000
    C-Stick/Up = `Right Y+`
    C-Stick/Down = `Right Y-`
    C-Stick/Left = `Right X-`
    C-Stick/Right = `Right X+`

    # Triggers (L2 and R2 on PS4)
    Triggers/L = `Trigger L` # L2 on PS4
    Triggers/R = `Trigger R` # R2 on PS4
    Triggers/L-Analog = `Trigger L`
    Triggers/R-Analog = `Trigger R`

  # Manage the GameCube controller configuration for player 2
  xdg.configFile."dolphin-emu/Config/GCPadNew_2.ini".text = ''
    [Profile]
    Device = SDL/1/PLAYSTATION(R)4 Controller

    D-Pad/Up = `Pad N`
    D-Pad/Down = `Pad S`
    D-Pad/Left = `Pad W`
    D-Pad/Right = `Pad E`
    
    Buttons/A = `Button B`
    Buttons/B = `Button A`
    Buttons/X = `Button Y`
    Buttons/Y = `Button X`
    Buttons/Z = `Shoulder R`
    Buttons/Start = Start

    Main Stick/Radius = 60.000000000000000
    Main Stick/Dead Zone = 12.000000000000000
    Main Stick/Up = `Left Y+`
    Main Stick/Down = `Left Y-`
    Main Stick/Left = `Left X-`
    Main Stick/Right = `Left X+`

    C-Stick/Radius = 65.000000000000000
    C-Stick/Dead Zone = 17.000000000000000
    C-Stick/Up = `Right Y+`
    C-Stick/Down = `Right Y-`
    C-Stick/Left = `Right X-`
    C-Stick/Right = `Right X+`

    Triggers/L = `Trigger L`
    Triggers/R = `Trigger R`
    Triggers/L-Analog = `Trigger L`
    Triggers/R-Analog = `Trigger R`
  '';
}