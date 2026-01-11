{ config, pkgs, ... }:

{
  # Enable the X11 windowing system if it's not already
  services.xserver.enable = true;

  # Enable 32-bit support for graphics, which is needed for most games
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # NVIDIA-specific configurations
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Enable modesetting - required for Wayland and helps with multi-monitor
    modesetting.enable = true;

    # Use the open source kernel modules (for newer GPUs)
    open = true;

    # Power management settings
    powerManagement = {
      enable = true;
      finegrained = false;  # Set to false for desktop, true for laptops with Turing+
    };

    nvidiaPersistenced = true;

    # Force full composition pipeline can help with screen tearing and 
    # some wake-from-sleep issues (uncomment if needed)
    # forceFullCompositionPipeline = true;
  };

  # Allow unfree packages since the NVIDIA driver is proprietary
  nixpkgs.config.allowUnfree = true;
}
