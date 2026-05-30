{
  fetchFromGitHub,
  libjxl,
  libjxlVersion ? "0.12.0-dev",
  libjxlRev ? "714ce6b64cd859675e470d519a338a132fe7b1c1",
  libjxlHash ? "sha256-X3DQzZLaSZdde615WaBg9WXm/MIKWm1ksiNFW1s+yOs=",
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
