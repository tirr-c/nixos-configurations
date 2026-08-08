{ ... }:

{
  services.immich = {
    enable = true;

    host = "0.0.0.0";
    port = 54080;
    openFirewall = true;

    mediaLocation = "/srv/chihiro/photos";
    accelerationDevices = ["/dev/dri/renderD128"];
    settings = {
      server.externalDomain = "https://photos.veritas.tirr.network";

      oauth = {
        enabled = true;
        autoLaunch = true;
        autoRegister = true;
        buttonText = "Login with Keycloak";

        clientId = "immich";
        issuerUrl = "https://keycloak.veritas.tirr.network/realms/master";
        signingAlgorithm = "ES256";
        scope = "openid email profile";
        roleClaim = "immich_role";
        storageLabelClaim = "preferred_username";
        storageQuotaClaim = "immich_quota";
        timeout = 30000;

        mobileOverrideEnabled = false;

        defaultStorageQuota = null;
      };

      ffmpeg = {
        accel = "nvenc";
      };

      # Tuned for Korean
      machineLearning = {
        clip.modelName = "nllb-clip-base-siglip__mrl";
        ocr.modelName = "KOREAN__PP-OCRv5_mobile";
      };
    };
  };
}
