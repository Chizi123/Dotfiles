{ config, libs, pkgs, modulesPath, ... }:

{
  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedZstdSettings = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "joelgrun@gmail.com";
    # "*.ush.bouncr.xyz".email = "joelgrun@gmail.com";
  };
}
