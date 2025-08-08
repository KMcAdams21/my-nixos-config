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

  
  # This configuration creates a profile for Player 1 (PS4-1.ini)
  # It is now placed in the Profiles/GCPad subdirectory as you discovered
  xdg.configFile."dolphin-emu/Profiles/GCPad/PS4-1.ini".text = ''
    [Profile]
    # This is the device name you provided
    Device = SDL/0/PS4 Controller
    
    # D-Pad mappings
    D-Pad/Up = `Pad N`
    D-Pad/Down = `Pad S`
    D-Pad/Left = `Pad W`
    D-Pad/Right = `Pad E`
    
    # Face Button mappings
    Buttons/A = `Button S`
    Buttons/B = `Button E`
    Buttons/X = `Button W`
    Buttons/Y = `Button N`
    Buttons/Start = Start

    # Main Stick (Left Analog Stick on PS4)
    # The calibration lines have been removed for standard behavior
    Main Stick/Up = `Left Y+`
    Main Stick/Down = `Left Y-`
    Main Stick/Left = `Left X-`
    Main Stick/Right = `Left X+`

    # C-Stick (Right Analog Stick on PS4)
    # The calibration lines have also been removed here
    C-Stick/Up = `Right Y+`
    C-Stick/Down = `Right Y-`
    C-Stick/Left = `Right X-`
    C-Stick/Right = `Right X+`

    # Trigger mappings
    Triggers/L = `Trigger L`
    Triggers/R = `Trigger R`
    Triggers/L-Analog = `Trigger L`
    Triggers/R-Analog = `Trigger R`
  '';

  # This configuration creates a profile for Player 2 (PS4-2.ini)
  # It is also placed in the Profiles/GCPad subdirectory
  xdg.configFile."dolphin-emu/Profiles/GCPad/PS4-2.ini".text = ''
    [Profile]
    # This is for the second controller
    Device = SDL/1/PS4 Controller

    # D-Pad mappings
    D-Pad/Up = `Pad N`
    D-Pad/Down = `Pad S`
    D-Pad/Left = `Pad W`
    D-Pad/Right = `Pad E`
    
    # Face Button mappings
    Buttons/A = `Button E`
    Buttons/B = `Button S`
    Buttons/X = `Button W`
    Buttons/Y = `Button N`
    Buttons/Z = `Shoulder R`
    Buttons/Start = Start

    # Main Stick (Left Analog Stick on PS4)
    Main Stick/Up = `Left Y+`
    Main Stick/Down = `Left Y-`
    Main Stick/Left = `Left X-`
    Main Stick/Right = `Left X+`

    # C-Stick (Right Analog Stick on PS4)
    C-Stick/Up = `Right Y+`
    C-Stick/Down = `Right Y-`
    C-Stick/Left = `Right X-`
    C-Stick/Right = `Right X+`

    # Trigger mappings
    Triggers/L = `Trigger L`
    Triggers/R = `Trigger R`
    Triggers/L-Analog = `Trigger L`
    Triggers/R-Analog = `Trigger R`
  '';
}