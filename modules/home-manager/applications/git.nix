{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Kendrick";
    userEmail = "mcadams.kendrick@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      push = {
        autoSetupRemote = true;
      };
    };
  };
}
