{
  fetchFromGitHub,
  libjxl,
  libjxlVersion ? "0.13.0-dev",
  libjxlRev ? "ef67fde2ec16d52e644c5a0969230b9a85e3eb31",
  libjxlHash ? "sha256-EjjOIywcihNUkTvoagdNbVWSl4TpwFRtTrqcwIZkLyE=",
  ninja,
}:

let
  version = "${libjxlVersion}-${libjxlRev}";
  libjxl' = libjxl.override {
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
