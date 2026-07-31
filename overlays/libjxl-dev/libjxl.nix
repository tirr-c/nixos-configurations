{
  fetchFromGitHub,
  libjxl,
  libjxlVersion ? "0.13.0-dev",
  libjxlRev ? "196a43d996aa6ed33ebf98812a7c6d43b2b6d01b",
  libjxlHash ? "sha256-3FttoL7ULJI/ujPiIlYhNUNHaTODZYyaw1Ki1ao0Tys=",
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
