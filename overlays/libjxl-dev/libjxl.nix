{
  fetchFromGitHub,
  libjxl,
  libjxlVersion ? "0.13.0-dev",
  libjxlRev ? "b87738951c1254cd8cccaa6d47712ba735da56d8",
  libjxlHash ? "sha256-IN6QUsoQ5B3TLswONPKYHG4ja89S6lv0uVVCQ8/TO8U=",
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
