{ config, ... }:

{
  security.acme.acceptTerms = true;
  security.acme.defaults = {
    email = "retica@tirr.dev";

    dnsProvider = "cloudflare";
    credentialFiles = {
      CF_DNS_API_TOKEN_FILE = config.age.secrets."cloudflare-token-tirr.network".path;
    };
  };
}
