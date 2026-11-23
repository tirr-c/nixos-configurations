{ config, inputs, ... }:

let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = config.nixpkgs.hostPlatform.system;
  };
in

{
  services.immich = {
    enable = true;
    package = pkgsUnstable.immich;

    host = "0.0.0.0";
    port = 54080;
    openFirewall = true;

    mediaLocation = "/srv/data/immich";
    settings = {
      server = {
        externalDomain = "https://photos.tirr.dev";
        publicUsers = false;
      };

      image = {
        preview = {
          enabled = true;
          format = "jxl";
          quality = 80;
          size = 1280;
        };
        thumbnail = {
          enabled = true;
          format = "jxl";
          quality = 80;
          size = 256;
        };
        extractEmbedded = true;
      };

      # Tuned for Korean
      machineLearning = {
        clip.modelName = "nllb-clip-base-siglip__mrl";
        ocr.modelName = "KOREAN__PP-OCRv5_mobile";
      };
    };

    machine-learning.environment = {
      MACHINE_LEARNING_MODEL_REVISION = "v2";
    };
  };
}
