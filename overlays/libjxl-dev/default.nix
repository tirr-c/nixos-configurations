pkgs: prev:

let
  inherit (pkgs) fetchFromGitHub;

  libhwyRev = "c02c0e318b22b1e456601ec392d80e679ef6bc1e";
  libhwy-dev = pkgs.libhwy.overrideAttrs {
    version = "1.2.0-unstable-${libhwyRev}";
    src = fetchFromGitHub {
      owner = "google";
      repo = "highway";
      rev = libhwyRev;
      hash = "sha256-LOLIv40Rp5GECnQM+khvoDmlj/yOp0RmX5Oyj/F+uas=";
    };
  };

  libjxlRev = "5e1e55301ce55b3a7241ca5b5a981633498558f4";
  libjxl-dev = (pkgs.libjxl.override {
    libhwy = libhwy-dev;
    enablePlugins = false;
  }).overrideAttrs (prev: {
    version = "0.12.0-dev-${libjxlRev}";
    src = fetchFromGitHub {
      owner = "libjxl";
      repo = "libjxl";
      rev = libjxlRev;
      hash = "sha256-vA+ojEQgd9odVylpVbIxFmd/CJewwjPd9TPlNt3tWk4=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = prev.nativeBuildInputs ++ [pkgs.ninja];
    cmakeFlags = ["-GNinja"] ++ prev.cmakeFlags;
  });
in

{
  inherit libjxl-dev;
}
