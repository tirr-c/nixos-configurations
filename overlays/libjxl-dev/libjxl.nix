{
  fetchFromGitHub,
  libjxl,
  libjxlVersion ? "0.12.0-dev",
  libjxlRev ? "462d28d89c151308278ac704db3daed5db07106a",
  libjxlHash ? "sha256-UWPdfLMLcgVWiBVkYvdGu4Ve9pTSkXIAbMZTxLydkWw=",
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
