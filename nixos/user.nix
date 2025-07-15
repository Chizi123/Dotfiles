{ config, libs, pkgs, modulesPath, ... }:

{
    users.users.joel = {
    isNormalUser = true;
    description = "Joel Grunbaum";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIATFC5gWcw58fSBHwfn+3FoAnxZfJEJH1bCe5cQof0YN joelgrun@gmail.com" ];
    packages = with pkgs; [];
  };
}
