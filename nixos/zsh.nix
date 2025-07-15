{ config, libs, pkgs, modulesPath, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    #autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
}
