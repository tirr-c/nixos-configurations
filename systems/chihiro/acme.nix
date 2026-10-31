{ config, ... }:

{
  security.acme.acceptTerms = true;
  security.acme.defaults = {
    email = "me@tirr.dev";

    dnsProvider = "cloudflare";
    credentialFiles = {
      CF_DNS_API_TOKEN_FILE = config.age.secrets.cloudflare-token.path;
    };
  };
}
