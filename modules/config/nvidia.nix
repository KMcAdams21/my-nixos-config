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
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = true;

  # Allow unfree packages since the NVIDIA driver is proprietary
  nixpkgs.config.allowUnfree = true;
}
