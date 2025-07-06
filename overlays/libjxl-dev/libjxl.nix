{
  fetchFromGitHub,
  libhwy,
  libhwyVersion ? "1.2.0-unstable",
  libhwyRev ? "c02c0e318b22b1e456601ec392d80e679ef6bc1e",
  libhwyHash ? "sha256-LOLIv40Rp5GECnQM+khvoDmlj/yOp0RmX5Oyj/F+uas=",
  libjxl,
  libjxlVersion ? "0.12.0-dev",
  libjxlRev ? "5e1e55301ce55b3a7241ca5b5a981633498558f4",
  libjxlHash ? "sha256-vA+ojEQgd9odVylpVbIxFmd/CJewwjPd9TPlNt3tWk4=",
  ninja,
}:

let
  libhwy' = libhwy.overrideAttrs {
    version = "${libhwyVersion}-${libhwyRev}";
    src = fetchFromGitHub {
      owner = "google";
      repo = "highway";
      rev = libhwyRev;
      hash = libhwyHash;
    };
  };

  version = "${libjxlVersion}-${libjxlRev}";
  libjxl' = libjxl.override {
    libhwy = libhwy';
    enablePlugins = false;
  };
in

libjxl'.overrideAttrs (prev: {
  inherit version;
  src = fetchFromGitHub {
    owner = "libjxl";
    repo = "libjxl";
    rev = libjxlRev;
    hash = libjxlHash;
    fetchSubmodules = true;
  };

  nativeBuildInputs = prev.nativeBuildInputs ++ [ninja];
  cmakeFlags = ["-GNinja"] ++ prev.cmakeFlags;
})
