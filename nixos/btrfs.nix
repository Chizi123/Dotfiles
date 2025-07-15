{ config, libs, pkgs, modulesPath, ... }:

{
  services.btrfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
  };
}
