{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Kendrick";
        email = "mcadams.kendrick@gmail.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };
}
